defmodule Localize.Inputs.Visualizer.Assets do
  @moduledoc false

  @css """
  :root {
    --li-bg:           #f7f8fa;
    --li-surface:      #ffffff;
    --li-surface-2:    #f1f3f6;
    --li-border:       #e1e4ea;
    --li-text:         #15181d;
    --li-text-dim:     #4b5563;
    --li-text-faint:   #6b7280;
    --li-accent:       #2563eb;
    --li-accent-soft:  rgba(37, 99, 235, 0.12);
    --li-accent-strong:#1d4ed8;
    --li-accent-fg:    #ffffff;
    --li-error:        #b91c1c;
    --li-error-bg:     #fef2f2;
    --li-pill-bg:      #e5e7eb;
    --li-pill-fg:      #374151;
    --li-radius:       0.5rem;
    --li-radius-sm:    0.375rem;
    --li-radius-pill:  9999px;
    --li-shadow-sm:    0 1px 2px rgba(15, 23, 42, 0.06);
    --li-shadow-md:    0 4px 14px rgba(15, 23, 42, 0.08);
    --li-mono:         ui-monospace, "SF Mono", Menlo, Consolas, monospace;
  }

  [data-theme="dark"] {
    --li-bg:           #0b0d10;
    --li-surface:      #15181d;
    --li-surface-2:    #1d2127;
    --li-border:       #2a2f37;
    --li-text:         #e5e7eb;
    --li-text-dim:     #9ca3af;
    --li-text-faint:   #6b7280;
    --li-accent:       #60a5fa;
    --li-accent-soft:  rgba(96, 165, 250, 0.16);
    --li-accent-strong:#3b82f6;
    --li-accent-fg:    #0b0d10;
    --li-error:        #fca5a5;
    --li-error-bg:     rgba(252, 165, 165, 0.12);
    --li-pill-bg:      #2a2f37;
    --li-pill-fg:      #e5e7eb;
    --li-shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.4);
    --li-shadow-md:    0 4px 14px rgba(0, 0, 0, 0.35);
  }

  @media (prefers-color-scheme: dark) {
    :root:not([data-theme]) {
      --li-bg:           #0b0d10;
      --li-surface:      #15181d;
      --li-surface-2:    #1d2127;
      --li-border:       #2a2f37;
      --li-text:         #e5e7eb;
      --li-text-dim:     #9ca3af;
      --li-text-faint:   #6b7280;
      --li-accent:       #60a5fa;
      --li-accent-soft:  rgba(96, 165, 250, 0.16);
      --li-accent-strong:#3b82f6;
      --li-accent-fg:    #0b0d10;
      --li-error:        #fca5a5;
      --li-error-bg:     rgba(252, 165, 165, 0.12);
      --li-pill-bg:      #2a2f37;
      --li-pill-fg:      #e5e7eb;
      --li-shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.4);
      --li-shadow-md:    0 4px 14px rgba(0, 0, 0, 0.35);
    }
  }

  * { box-sizing: border-box; }
  html, body {
    margin: 0;
    background: var(--li-bg);
    color: var(--li-text);
    font: 14px/1.55 ui-sans-serif, system-ui, -apple-system, "Segoe UI",
                   Roboto, "Helvetica Neue", Arial, sans-serif;
    transition: background 120ms ease, color 120ms ease;
  }

  .li-header {
    background: var(--li-surface);
    border-bottom: 1px solid var(--li-border);
    padding: 1.25rem 2rem 0;
  }
  .li-header-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1.5rem;
    margin-bottom: 1rem;
  }
  .li-brand { text-decoration: none; color: inherit; display: inline-flex; align-items: center; gap: 0.85rem; }
  .li-brand-text { display: flex; flex-direction: column; }
  .li-brand h1 { font-size: 1.25rem; margin: 0 0 0.15rem; font-weight: 700; letter-spacing: -0.01em; }
  .li-brand p { color: var(--li-text-dim); margin: 0; font-size: 0.85rem; }

  .li-tabs { display: flex; gap: 0.25rem; }
  .li-tabs a {
    text-decoration: none;
    padding: 0.55rem 1rem;
    color: var(--li-text-dim);
    border-bottom: 2px solid transparent;
    font-weight: 500;
    font-size: 0.9rem;
    transition: color 120ms ease, border-color 120ms ease;
  }
  .li-tabs a.active { color: var(--li-accent); border-bottom-color: var(--li-accent); }
  .li-tabs a:hover { color: var(--li-text); }

  .li-theme-toggle {
    position: relative;
    display: inline-flex;
    align-items: center;
    background: var(--li-surface-2);
    border: 1px solid var(--li-border);
    border-radius: var(--li-radius-pill);
    padding: 2px;
  }
  .li-theme-toggle button {
    position: relative;
    z-index: 1;
    border: 0;
    background: transparent;
    color: var(--li-text-dim);
    font: inherit;
    cursor: pointer;
    padding: 0.3rem 0.6rem;
    border-radius: var(--li-radius-pill);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 1.75rem;
    transition: color 120ms ease;
  }
  .li-theme-toggle button:hover { color: var(--li-text); }
  .li-theme-toggle button[aria-pressed="true"] { color: var(--li-text); }
  .li-theme-toggle-thumb {
    position: absolute;
    top: 2px;
    left: 2px;
    width: calc((100% - 4px) / 3);
    height: calc(100% - 4px);
    background: var(--li-surface);
    border-radius: var(--li-radius-pill);
    box-shadow: var(--li-shadow-sm);
    transition: transform 180ms cubic-bezier(0.4, 0, 0.2, 1);
    pointer-events: none;
  }
  .li-theme-toggle[data-active="system"] .li-theme-toggle-thumb { transform: translateX(0%); }
  .li-theme-toggle[data-active="light"]  .li-theme-toggle-thumb { transform: translateX(100%); }
  .li-theme-toggle[data-active="dark"]   .li-theme-toggle-thumb { transform: translateX(200%); }
  @media (prefers-reduced-motion: reduce) {
    .li-theme-toggle-thumb { transition: none; }
    html, body { transition: none; }
  }
  .li-theme-toggle svg {
    width: 14px;
    height: 14px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
  }

  .li-main { max-width: 60rem; margin: 0 auto; padding: 2rem; }

  .li-card {
    background: var(--li-surface);
    border: 1px solid var(--li-border);
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 1.25rem;
    box-shadow: var(--li-shadow-sm);
  }
  .li-card h2 { font-size: 1rem; margin: 0 0 0.25rem; font-weight: 600; }
  .li-card p.li-desc { color: var(--li-text-dim); margin: 0 0 1.25rem; font-size: 0.9rem; max-width: 60ch; }

  form.li-form {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem 1.25rem;
    margin-bottom: 1rem;
  }
  form.li-form .li-field-wide { grid-column: 1 / -1; }
  form.li-form .li-actions {
    grid-column: 1 / -1;
    display: flex;
    gap: 0.5rem;
    align-items: center;
    margin-top: 0.25rem;
  }

  .li-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .li-field label {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
    font-size: 0.7rem;
    color: var(--li-text-dim);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }
  .li-field input[type="text"],
  .li-field input[type="search"],
  .li-field select,
  .li-field textarea,
  .li-field select option {
    font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
                 "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    font-size: 0.9rem;
    font-weight: 400;
    text-transform: none;
    letter-spacing: normal;
  }
  .li-field input[type="text"],
  .li-field input[type="search"],
  .li-field select,
  .li-field textarea {
    padding: 0.45rem 0.7rem;
    border: 1px solid var(--li-border);
    border-radius: var(--li-radius-sm);
    background: var(--li-surface-2);
    color: var(--li-text);
    line-height: 1.4;
  }
  .li-field input:focus, .li-field select:focus {
    outline: none;
    border-color: var(--li-accent);
    box-shadow: 0 0 0 3px var(--li-accent-soft);
  }
  .li-field select option { background: var(--li-surface); color: var(--li-text); }
  .li-hint {
    color: var(--li-text-faint);
    font-size: 0.78rem;
    text-transform: none;
    letter-spacing: 0;
    font-weight: normal;
  }
  button.li-btn {
    font: inherit;
    background: var(--li-accent);
    color: var(--li-accent-fg);
    border: none;
    padding: 0.55rem 1.25rem;
    border-radius: var(--li-radius-sm);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    transition: background 120ms ease;
  }
  button.li-btn:hover { background: var(--li-accent-strong); }

  .li-result {
    display: grid;
    grid-template-columns: 12rem 1fr;
    gap: 0.45rem 1rem;
    background: var(--li-surface-2);
    padding: 1rem 1.25rem;
    border-radius: var(--li-radius);
    font-size: 0.9rem;
  }
  .li-result dt {
    color: var(--li-text-dim);
    font-weight: 500;
    font-size: 0.78rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding-top: 0.2rem;
  }
  .li-result dd { margin: 0; font-family: var(--li-mono); }
  .li-result dd.li-bad { color: var(--li-error); }

  table.li-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 0.5rem;
    font-size: 0.9rem;
  }
  table.li-table th, table.li-table td {
    padding: 0.5rem 0.75rem;
    text-align: left;
    border-bottom: 1px solid var(--li-border);
    vertical-align: top;
  }
  table.li-table th {
    background: var(--li-surface-2);
    font-weight: 600;
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--li-text-dim);
  }
  table.li-table td.li-mono { font-family: var(--li-mono); }
  table.li-table td.li-bad { color: var(--li-error); }

  .li-code {
    background: var(--li-surface-2);
    color: var(--li-text);
    padding: 1rem 1.25rem;
    border-radius: var(--li-radius);
    margin: 0;
    font-family: var(--li-mono);
    font-size: 0.82rem;
    line-height: 1.55;
    overflow-x: auto;
  }
  code, .li-code-inline {
    font-family: var(--li-mono);
    background: var(--li-surface-2);
    padding: 0.1rem 0.35rem;
    border-radius: 0.25rem;
    font-size: 0.85em;
  }

  .li-error {
    background: var(--li-error-bg);
    color: var(--li-error);
    border: 1px solid var(--li-error);
    padding: 0.75rem 1rem;
    border-radius: var(--li-radius);
    margin-bottom: 1rem;
  }
  .li-footer {
    margin-top: 3rem;
    color: var(--li-text-faint);
    font-size: 0.82rem;
    text-align: center;
  }

  /* Theme the embedded component to track the visualizer palette */
  .number-input-wrapper {
    background: var(--li-surface-2);
    border-color: var(--li-border);
  }
  .number-input-wrapper:focus-within {
    border-color: var(--li-accent);
    outline-color: var(--li-accent);
    box-shadow: 0 0 0 3px var(--li-accent-soft);
  }
  .number-input-field { color: var(--li-text); background: transparent; }
  """

  @spec css() :: String.t()
  def css, do: @css

  @external_resource Path.join(:code.priv_dir(:localize_inputs), "static/localize_inputs.css")
  @external_resource Path.join(:code.priv_dir(:localize_inputs), "static/localize_inputs.js")

  @component_css File.read!(
                   Path.join(:code.priv_dir(:localize_inputs), "static/localize_inputs.css")
                 )
  @component_js File.read!(
                  Path.join(:code.priv_dir(:localize_inputs), "static/localize_inputs.js")
                )

  @spec component_css() :: String.t()
  def component_css, do: @component_css

  @spec component_js() :: String.t()
  def component_js, do: @component_js
end
