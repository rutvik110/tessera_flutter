//! Flutter-facing API over the local Tessera crate.
//!
//! The bundled Safetensors weights are compiled into this library. Offsets
//! returned to Dart are UTF-16 code units, so `text.substring(start, end)`
//! yields the same span. `end` is exclusive.

use std::fmt;

const BUNDLE: &[u8] = include_bytes!("../../models/tessera-v1.safetensors");
const CHECKSUM: &str = include_str!("../../models/tessera-v1.sha256");

/// A loaded Tessera extractor. One instance can serve many calls.
///
/// Rules-only kinds (`email` and `phone`) do not read the weight bundle.
/// Any other kind loads and checksums the bundled model.
#[flutter_rust_bridge::frb(opaque)]
pub struct Extractor {
    inner: tessera::Tessera,
}

impl Extractor {
    /// Load an extractor for `kinds`. An empty list serves every kind.
    pub fn load(kinds: Vec<EntityKind>) -> Result<Extractor, TesseraError> {
        let set = kind_set(&kinds);
        let (bytes, checksum) = if set.is_rules_only() {
            (&[][..], None)
        } else {
            (BUNDLE, Some(CHECKSUM.trim()))
        };
        let inner = tessera::Tessera::load(
            bytes,
            tessera::Config {
                kinds: set,
                expected_checksum: checksum,
            },
        )
        .map_err(TesseraError::from)?;
        Ok(Extractor { inner })
    }

    /// Kinds this extractor was loaded for, in taxonomy order.
    pub fn kinds(&self) -> Vec<EntityKind> {
        tessera::Kind::ALL
            .into_iter()
            .filter(|kind| self.inner.kinds().contains(*kind))
            .map(EntityKind::from)
            .collect()
    }

    /// Every supported entity in `text`, in document order.
    pub fn detect(
        &self,
        text: String,
        options: CallOptions,
    ) -> Result<Vec<TextEntity>, TesseraError> {
        let found = with_query(&options, |query| self.inner.detect(&text, query))?;
        Ok(map_entities(&text, &found))
    }

    /// Entities from [`detect`](Self::detect), grouped into contacts.
    ///
    /// Details the grouper will not assign are returned in `unassigned`.
    pub fn extract_contacts(
        &self,
        text: String,
        options: CallOptions,
    ) -> Result<ContactExtraction, TesseraError> {
        let found = with_query(&options, |query| self.inner.extract_contacts(&text, query))?;
        Ok(map_extraction(&text, &found))
    }

    /// Split text already known to be one address. Offsets are relative to `text`.
    ///
    /// At most 256 non-whitespace tokens and 8 KiB. Only `include_uncertain` applies.
    pub fn parse_address(
        &self,
        text: String,
        include_uncertain: bool,
    ) -> Result<TextEntity, TesseraError> {
        let query = tessera::Query {
            include_uncertain,
            ..tessera::Query::default()
        };
        let found = self
            .inner
            .parse_address(&text, &query)
            .map_err(TesseraError::from)?;
        Ok(map_entities(&text, std::slice::from_ref(&found))
            .into_iter()
            .next()
            .expect("parse_address returns one entity"))
    }
}

/// What to look for.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EntityKind {
    Person,
    Org,
    Address,
    Email,
    Phone,
}

impl From<EntityKind> for tessera::Kind {
    fn from(kind: EntityKind) -> Self {
        match kind {
            EntityKind::Person => tessera::Kind::Person,
            EntityKind::Org => tessera::Kind::Org,
            EntityKind::Address => tessera::Kind::Address,
            EntityKind::Email => tessera::Kind::Email,
            EntityKind::Phone => tessera::Kind::Phone,
        }
    }
}

impl From<tessera::Kind> for EntityKind {
    fn from(kind: tessera::Kind) -> Self {
        match kind {
            tessera::Kind::Person => EntityKind::Person,
            tessera::Kind::Org => EntityKind::Org,
            tessera::Kind::Address => EntityKind::Address,
            tessera::Kind::Email => EntityKind::Email,
            tessera::Kind::Phone => EntityKind::Phone,
        }
    }
}

/// Which stage produced an entity.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EntitySource {
    Model,
    Rules,
}

impl From<tessera::Source> for EntitySource {
    fn from(source: tessera::Source) -> Self {
        match source {
            tessera::Source::Model => EntitySource::Model,
            tessera::Source::Rules => EntitySource::Rules,
        }
    }
}

/// Address component labels, in taxonomy order.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AddressLabel {
    HouseNumber,
    Road,
    Unit,
    Level,
    Suburb,
    City,
    District,
    Region,
    Postcode,
    Country,
    PoBox,
    Unknown,
}

impl From<tessera::AddressLabel> for AddressLabel {
    fn from(label: tessera::AddressLabel) -> Self {
        match label {
            tessera::AddressLabel::HouseNumber => AddressLabel::HouseNumber,
            tessera::AddressLabel::Road => AddressLabel::Road,
            tessera::AddressLabel::Unit => AddressLabel::Unit,
            tessera::AddressLabel::Level => AddressLabel::Level,
            tessera::AddressLabel::Suburb => AddressLabel::Suburb,
            tessera::AddressLabel::City => AddressLabel::City,
            tessera::AddressLabel::District => AddressLabel::District,
            tessera::AddressLabel::Region => AddressLabel::Region,
            tessera::AddressLabel::Postcode => AddressLabel::Postcode,
            tessera::AddressLabel::Country => AddressLabel::Country,
            tessera::AddressLabel::PoBox => AddressLabel::PoBox,
            tessera::AddressLabel::Unknown => AddressLabel::Unknown,
        }
    }
}

/// One labelled piece of an address.
#[derive(Debug, Clone, PartialEq)]
pub struct AddressComponent {
    pub label: AddressLabel,
    /// The component's own text.
    pub text: String,
    /// UTF-16 code unit where the span begins in the source string.
    pub start: u32,
    /// UTF-16 code unit where the span ends, exclusive.
    pub end: u32,
    /// Confidence from 0 to 1, rounded to four decimal places.
    pub confidence: f64,
}

/// One detected span.
#[derive(Debug, Clone, PartialEq)]
pub struct TextEntity {
    pub kind: EntityKind,
    /// The span's own text, sliced from the source.
    pub text: String,
    /// UTF-16 code unit where the span begins.
    pub start: u32,
    /// UTF-16 code unit where the span ends, exclusive.
    pub end: u32,
    /// Confidence from 0 to 1, rounded to four decimal places.
    pub confidence: f64,
    /// Medium confidence: returned, but a person should look before acting on it.
    pub review_recommended: bool,
    pub source: EntitySource,
    /// Address components. Empty for every other kind.
    pub components: Vec<AddressComponent>,
    /// E.164 for phones, or an email with its domain lowercased.
    pub normalized: Option<String>,
    /// Phone only, ISO 3166-1 alpha-2.
    pub region: Option<String>,
}

/// A person or organization and the details assigned to them.
#[derive(Debug, Clone, PartialEq)]
pub struct Contact {
    pub start: u32,
    pub end: u32,
    pub confidence: f64,
    pub review_recommended: bool,
    pub person: Option<TextEntity>,
    pub org: Option<TextEntity>,
    pub addresses: Vec<TextEntity>,
    pub emails: Vec<TextEntity>,
    pub phones: Vec<TextEntity>,
}

/// Contacts in document order, plus entities left unassigned.
#[derive(Debug, Clone, PartialEq)]
pub struct ContactExtraction {
    pub contacts: Vec<Contact>,
    pub unassigned: Vec<TextEntity>,
}

/// Per-call options for [`Extractor::detect`] and [`Extractor::extract_contacts`].
#[derive(Debug, Clone)]
pub struct CallOptions {
    /// Regions for phone numbers written without a country code, tried in order.
    /// Empty asks Tessera to infer them from the document.
    pub country_hint: Vec<String>,
    /// Also return low-confidence results. Detector thresholds still apply first.
    pub include_uncertain: bool,
    pub format: InputFormat,
    pub markdown: MarkdownScan,
}

/// What the input text is.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InputFormat {
    /// Plain text. Every byte may be scanned.
    Plain,
    /// Markdown. Only prose is scanned, and `mailto:` / `tel:` link destinations count.
    Markdown,
}

/// How Markdown input is selected for scanning.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MarkdownScan {
    /// Scan fenced, indented, and inline code. Off by default.
    pub include_code: bool,
    /// Scan raw HTML blocks and inline HTML as text. Off by default.
    pub include_html: bool,
    /// Parse GFM tables so each cell is its own range. On by default.
    pub gfm_tables: bool,
}

impl Default for MarkdownScan {
    fn default() -> Self {
        Self {
            include_code: false,
            include_html: false,
            gfm_tables: true,
        }
    }
}

/// Failures from loading the bundle or running inference.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TesseraError {
    /// The bundle is malformed, or lacks a network the requested kinds need.
    BundleInvalid,
    /// The bundled bytes do not match the shipped checksum.
    ChecksumMismatch,
    /// The bundle was built for another format or library version.
    UnsupportedVersion,
    /// The input is longer than the operation accepts.
    InputTooLarge,
    /// Markdown was requested from a build compiled without that feature.
    UnsupportedFormat,
    /// An operation ran that this instance cannot serve, or an internal invariant broke.
    Inference { stage: String },
}

impl fmt::Display for TesseraError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TesseraError::BundleInvalid => write!(
                f,
                "weight bundle is invalid or lacks a network for the requested kinds"
            ),
            TesseraError::ChecksumMismatch => write!(f, "weight bundle checksum does not match"),
            TesseraError::UnsupportedVersion => {
                write!(f, "weight bundle was built for a different library version")
            }
            TesseraError::InputTooLarge => write!(f, "input exceeds the supported size"),
            TesseraError::UnsupportedFormat => {
                write!(f, "input format requires a feature that this build lacks")
            }
            TesseraError::Inference { stage } => {
                write!(f, "inference failed in stage `{stage}`")
            }
        }
    }
}

impl std::error::Error for TesseraError {}

impl From<tessera::Error> for TesseraError {
    fn from(err: tessera::Error) -> Self {
        match err {
            tessera::Error::BundleInvalid => TesseraError::BundleInvalid,
            tessera::Error::ChecksumMismatch => TesseraError::ChecksumMismatch,
            tessera::Error::UnsupportedVersion => TesseraError::UnsupportedVersion,
            tessera::Error::InputTooLarge => TesseraError::InputTooLarge,
            tessera::Error::UnsupportedFormat => TesseraError::UnsupportedFormat,
            tessera::Error::Inference { stage } => TesseraError::Inference {
                stage: stage.to_string(),
            },
        }
    }
}

fn kind_set(kinds: &[EntityKind]) -> tessera::KindSet {
    if kinds.is_empty() {
        return tessera::Kind::all();
    }
    kinds.iter().copied().fold(tessera::KindSet::EMPTY, |set, kind| {
        set | tessera::Kind::from(kind)
    })
}

fn with_query<T>(
    options: &CallOptions,
    run: impl FnOnce(&tessera::Query<'_>) -> Result<T, tessera::Error>,
) -> Result<T, TesseraError> {
    let hints: Vec<&str> = options.country_hint.iter().map(String::as_str).collect();
    let format = match options.format {
        InputFormat::Plain => tessera::Format::Text,
        InputFormat::Markdown => tessera::Format::Markdown(tessera::MarkdownOptions {
            include_code: options.markdown.include_code,
            include_html: options.markdown.include_html,
            gfm_tables: options.markdown.gfm_tables,
        }),
    };
    let query = tessera::Query {
        country_hint: &hints,
        include_uncertain: options.include_uncertain,
        format,
    };
    run(&query).map_err(TesseraError::from)
}

fn display_confidence(confidence: f32) -> f64 {
    (f64::from(confidence) * 10_000.0).round() / 10_000.0
}

fn entity_bytes(entity: &tessera::Entity) -> impl Iterator<Item = usize> + '_ {
    [entity.start, entity.end]
        .into_iter()
        .chain(entity.components.iter().flat_map(|c| [c.start, c.end]))
}

fn map_entities(text: &str, entities: &[tessera::Entity]) -> Vec<TextEntity> {
    let mut units = utf16_at(text, entities.iter().flat_map(entity_bytes)).into_iter();
    let mut next = || units.next().unwrap_or(0);
    entities
        .iter()
        .map(|entity| map_entity(text, entity, &mut next))
        .collect()
}

fn map_extraction(text: &str, extraction: &tessera::Extraction) -> ContactExtraction {
    let bytes = extraction
        .contacts
        .iter()
        .flat_map(|contact| {
            [contact.start, contact.end]
                .into_iter()
                .chain(contact.entities().flat_map(entity_bytes))
        })
        .chain(extraction.unassigned.iter().flat_map(entity_bytes));
    let mut units = utf16_at(text, bytes).into_iter();
    let mut next = || units.next().unwrap_or(0);
    ContactExtraction {
        contacts: extraction
            .contacts
            .iter()
            .map(|contact| map_contact(text, contact, &mut next))
            .collect(),
        unassigned: extraction
            .unassigned
            .iter()
            .map(|entity| map_entity(text, entity, &mut next))
            .collect(),
    }
}

fn map_contact(
    text: &str,
    contact: &tessera::Contact,
    next: &mut impl FnMut() -> u32,
) -> Contact {
    Contact {
        start: next(),
        end: next(),
        confidence: display_confidence(contact.confidence),
        review_recommended: contact.review_recommended,
        person: contact
            .person
            .as_ref()
            .map(|entity| map_entity(text, entity, next)),
        org: contact
            .org
            .as_ref()
            .map(|entity| map_entity(text, entity, next)),
        addresses: contact
            .addresses
            .iter()
            .map(|entity| map_entity(text, entity, next))
            .collect(),
        emails: contact
            .emails
            .iter()
            .map(|entity| map_entity(text, entity, next))
            .collect(),
        phones: contact
            .phones
            .iter()
            .map(|entity| map_entity(text, entity, next))
            .collect(),
    }
}

fn map_entity(text: &str, entity: &tessera::Entity, next: &mut impl FnMut() -> u32) -> TextEntity {
    TextEntity {
        kind: EntityKind::from(entity.kind),
        text: entity.text(text).to_string(),
        start: next(),
        end: next(),
        confidence: display_confidence(entity.confidence),
        review_recommended: entity.review_recommended,
        source: EntitySource::from(entity.source),
        components: entity
            .components
            .iter()
            .map(|component| AddressComponent {
                label: AddressLabel::from(component.label),
                text: component.text(text).to_string(),
                start: next(),
                end: next(),
                confidence: display_confidence(component.confidence),
            })
            .collect(),
        normalized: entity.normalized.clone(),
        region: entity.region.clone(),
    }
}

/// UTF-16 code units at each UTF-8 byte offset. Same conversion Tessera uses
/// at its JavaScript boundary. Offsets that are not char boundaries stop at
/// the last char that ends at or before the target.
fn utf16_at(text: &str, bytes: impl IntoIterator<Item = usize>) -> Vec<u32> {
    let wanted: Vec<usize> = bytes.into_iter().collect();
    let mut order: Vec<usize> = (0..wanted.len()).collect();
    order.sort_by_key(|&i| wanted[i]);
    let mut out = vec![0u32; wanted.len()];
    let (mut units, mut at, mut chars) = (0u32, 0usize, text.char_indices());
    for i in order {
        let target = wanted[i];
        while at < target {
            match chars.next() {
                Some((byte, ch)) => {
                    units += ch.len_utf16() as u32;
                    at = byte + ch.len_utf8();
                }
                None => break,
            }
        }
        out[i] = units;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = "Jordan Avery, Project Coordinator\nAcme Corporation\n500 Main St, Springfield, IL 62701\n+1 202-555-0199\njordan@acme.example";

    fn us_options() -> CallOptions {
        CallOptions {
            country_hint: vec!["US".to_string()],
            include_uncertain: false,
            format: InputFormat::Plain,
            markdown: MarkdownScan::default(),
        }
    }

    #[test]
    fn detects_the_readme_sample() {
        let extractor = Extractor::load(vec![]).unwrap();
        assert_eq!(extractor.kinds().len(), 5);
        let entities = extractor.detect(SAMPLE.to_string(), us_options()).unwrap();
        let email = entities
            .iter()
            .find(|entity| entity.kind == EntityKind::Email)
            .expect("email");
        assert_eq!(email.text, "jordan@acme.example");
        assert_eq!(email.normalized.as_deref(), Some("jordan@acme.example"));
        assert_eq!(
            &SAMPLE[email.start as usize..email.end as usize],
            email.text
        );
        let phone = entities
            .iter()
            .find(|entity| entity.kind == EntityKind::Phone)
            .expect("phone");
        assert_eq!(phone.normalized.as_deref(), Some("+12025550199"));
        assert_eq!(&SAMPLE[phone.start as usize..phone.end as usize], phone.text);

        let extraction = extractor
            .extract_contacts(SAMPLE.to_string(), us_options())
            .unwrap();
        assert!(!extraction.contacts.is_empty() || !extraction.unassigned.is_empty());
    }

    #[test]
    fn parses_a_postal_address() {
        let extractor = Extractor::load(vec![EntityKind::Address]).unwrap();
        let address = extractor
            .parse_address("400 Broad St, Seattle, WA 98109".to_string(), false)
            .unwrap();
        let labels: Vec<_> = address
            .components
            .iter()
            .map(|component| (component.label, component.text.as_str()))
            .collect();
        assert!(labels.contains(&(AddressLabel::Road, "Broad St")));
        assert!(labels.contains(&(AddressLabel::City, "Seattle")));
        assert!(labels.contains(&(AddressLabel::Region, "WA")));
        assert!(labels.contains(&(AddressLabel::Postcode, "98109")));
    }

    #[test]
    fn rules_only_skips_the_bundle() {
        let extractor = Extractor::load(vec![EntityKind::Email, EntityKind::Phone]).unwrap();
        let entities = extractor
            .detect("Write to jordan@acme.example".to_string(), us_options())
            .unwrap();
        assert_eq!(entities.len(), 1);
        assert_eq!(entities[0].source, EntitySource::Rules);
    }
}
