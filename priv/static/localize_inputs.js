// Localize.Inputs Phoenix LiveView hooks.
//
// Exports one hook today:
//
//   NumberInput — locale-aware live formatting for plain numbers
//
// AutoNumeric (https://autonumeric.org/) is a *peer* dependency.
// Install it in the host app:
//
//   npm install autonumeric
//
// And expose it on window before importing these hooks, or call
// `configure({ AutoNumeric })` before constructing your
// LiveSocket. Without AutoNumeric the hook degrades to the Path A
// baseline: the input still works, the server-side parser still
// accepts whatever the user typed, but live formatting and cursor
// preservation are off.

let AutoNumericCtor =
  (typeof window !== "undefined" && window.AutoNumeric) || null;

/** Inject a specific AutoNumeric constructor (for bundlers that
 *  don't put it on window). Call this before `new LiveSocket`. */
export function configure({ AutoNumeric }) {
  AutoNumericCtor = AutoNumeric || AutoNumericCtor;
}

function readData(el) {
  const d = el.dataset;
  const num = (v) => (v == null || v === "" ? null : Number(v));
  return {
    locale: d.locale || "en",
    decimal: d.decimal || ".",
    group: d.group || ",",
    minus: d.minus || "-",
    digitSystem: d.digitSystem || "latn",
    integer: d.integer === "true",
    decimals: num(d.decimals),
    min: d.min || null,
    max: d.max || null,
  };
}

function buildAutoNumericOptions(data) {
  const decimals = data.decimals ?? (data.integer ? 0 : 6);

  return {
    decimalCharacter: data.decimal,
    digitGroupSeparator: data.group,
    decimalCharacterAlternative: data.decimal === "." ? "," : ".",
    negativeSignCharacter: data.minus,
    decimalPlaces: decimals,
    decimalPlacesShownOnFocus: decimals,
    decimalPlacesShownOnBlur: decimals,
    allowDecimalPadding: false,
    currencySymbol: "",
    selectOnFocus: false,
    modifyValueOnWheel: false,
    minimumValue: data.min ?? "-10000000000000",
    maximumValue: data.max ?? "10000000000000",
    onInvalidPaste: "clamp",
    digitalGroupSpacing: data.locale && data.locale.startsWith("en-IN") ? "2s" : "3",
  };
}

function cssEscape(value) {
  if (typeof window !== "undefined" && window.CSS && CSS.escape) return CSS.escape(value);
  return value.replace(/[^a-zA-Z0-9_-]/g, "\\$&");
}

function paste_sanitize(event) {
  const text = (event.clipboardData || window.clipboardData).getData("text");
  if (!text) return;
  event.preventDefault();
  const cleaned = text
    .replace(/[   ]/g, " ")
    .replace(/[−–—]/g, "-")
    .replace(/^\((.*)\)$/, "-$1")
    .trim();
  const input = event.target;
  const start = input.selectionStart || 0;
  const end = input.selectionEnd || 0;
  input.value = input.value.slice(0, start) + cleaned + input.value.slice(end);
  const cursor = start + cleaned.length;
  input.setSelectionRange(cursor, cursor);
}

export const NumberInput = {
  mounted() {
    this.input = this.el.querySelector("input.number-input-field");
    if (!this.input) return;

    const data = readData(this.el);

    if (!AutoNumericCtor) {
      this.input.addEventListener("paste", paste_sanitize);
      return;
    }

    // No submit-time canonicalisation: the form value is the
    // user's locale-formatted string. The server parses it with
    // the locale. Wire format is identical with or without
    // AutoNumeric loaded — no canonical-vs-locale ambiguity for
    // the server to puzzle out.
    this.an = new AutoNumericCtor(this.input, buildAutoNumericOptions(data));
  },

  destroyed() {
    if (this.an) this.an.remove();
  },
};

export default { NumberInput, configure };
