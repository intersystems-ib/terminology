import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { authenticatedJsonRequest, type RequestRecord } from "../lib/api";
import { useAuth } from "../state/AuthContext";

type TabId = "search" | "crosswalk";

type RunResult = {
  request: RequestRecord;
  label: string;
};

type VectorFormState = {
  query: string;
  searchSystemUris: string[];
  searchReleaseIds: string;
  searchLang: string;
  sourceSystemUri: string;
  sourceReleaseId: string;
  sourceCode: string;
  targetSystemUris: string[];
  targetReleaseIds: string;
  crosswalkQuery: string;
  crosswalkLang: string;
  limit: string;
  model: string;
};

const SYSTEM_OPTIONS = [
  {
    label: "SNOMED CT",
    value: "http://snomed.info/sct"
  },
  {
    label: "LOINC",
    value: "http://loinc.org"
  },
  {
    label: "ICD-10-ES",
    value: "http://hl7.org/fhir/sid/icd-10-es"
  }
];

const defaultState: VectorFormState = {
  query: "neumonia adquirida en la comunidad",
  searchSystemUris: ["http://snomed.info/sct", "http://hl7.org/fhir/sid/icd-10-es"],
  searchReleaseIds: "",
  searchLang: "es",
  sourceSystemUri: "http://snomed.info/sct",
  sourceReleaseId: "SNOMED-ES-20250131",
  sourceCode: "233604007",
  targetSystemUris: ["http://hl7.org/fhir/sid/icd-10-es"],
  targetReleaseIds: "",
  crosswalkQuery: "",
  crosswalkLang: "es",
  limit: "10",
  model: "FremyCompany/BioLORD-2023-M"
};

export function VectorWorkspace() {
  const { session } = useAuth();
  const [activeTab, setActiveTab] = useState<TabId>("search");
  const [formState, setFormState] = useState<VectorFormState>(defaultState);
  const [collapsedSections, setCollapsedSections] = useState({
    operation: false,
    result: false,
    technical: false
  });
  const [isRunning, setIsRunning] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [lastResult, setLastResult] = useState<RunResult | null>(null);

  function updateField<K extends keyof VectorFormState>(
    field: K,
    value: VectorFormState[K]
  ) {
    setFormState((current) => ({ ...current, [field]: value }));
  }

  function toggleSection(section: keyof typeof collapsedSections) {
    setCollapsedSections((current) => ({
      ...current,
      [section]: !current[section]
    }));
  }

  function toggleMultiValue(
    field: "searchSystemUris" | "targetSystemUris",
    value: string
  ) {
    setFormState((current) => {
      const values = current[field];
      const nextValues = values.includes(value)
        ? values.filter((entry) => entry !== value)
        : [...values, value];

      return {
        ...current,
        [field]: nextValues
      };
    });
  }

  function appendRepeatedParam(name: string, values: string[]) {
    return values
      .filter((value) => value.trim() !== "")
      .map((value) => `&${name}=${encodeURIComponent(value.trim())}`)
      .join("");
  }

  function parseCsvValues(value: string) {
    return value
      .split(",")
      .map((entry) => entry.trim())
      .filter(Boolean);
  }

  async function runAction(label: string, path: string) {
    if (!session) {
      setErrorMessage("The current session is missing. Please log in again.");
      return;
    }

    setIsRunning(true);
    setErrorMessage(null);

    try {
      const request = await authenticatedJsonRequest(session, path, "application/json");
      setLastResult({ request, label });
    } catch (error) {
      const fallbackMessage =
        error instanceof Error ? error.message : "The vector request failed.";
      const requestRecord =
        typeof error === "object" && error !== null && "requestRecord" in error
          ? (error.requestRecord as RequestRecord)
          : null;

      if (requestRecord) {
        setLastResult({ request: requestRecord, label });
      }

      setErrorMessage(fallbackMessage);
    } finally {
      setIsRunning(false);
    }
  }

  async function handleSubmit() {
    const limit = encodeURIComponent(formState.limit);
    const model = encodeURIComponent(formState.model);

    if (activeTab === "search") {
      const releaseParams = appendRepeatedParam(
        "releaseId",
        parseCsvValues(formState.searchReleaseIds)
      );
      const systemParams = appendRepeatedParam("systemUri", formState.searchSystemUris);
      const langParam =
        formState.searchLang.trim() !== ""
          ? `&lang=${encodeURIComponent(formState.searchLang.trim())}`
          : "";

      await runAction(
        "Vector semantic search",
        `/terminology/vector/search?q=${encodeURIComponent(
          formState.query
        )}${systemParams}${releaseParams}${langParam}&limit=${limit}&model=${model}`
      );
      return;
    }

    const targetSystemParams = appendRepeatedParam(
      "targetSystemUri",
      formState.targetSystemUris
    );
    const targetReleaseParams = appendRepeatedParam(
      "targetReleaseId",
      parseCsvValues(formState.targetReleaseIds)
    );
    const langParam =
      formState.crosswalkLang.trim() !== ""
        ? `&lang=${encodeURIComponent(formState.crosswalkLang.trim())}`
        : "";

    const sourceParams =
      formState.crosswalkQuery.trim() !== ""
        ? `q=${encodeURIComponent(formState.crosswalkQuery.trim())}`
        : `sourceSystemUri=${encodeURIComponent(
            formState.sourceSystemUri
          )}&sourceReleaseId=${encodeURIComponent(
            formState.sourceReleaseId
          )}&sourceCode=${encodeURIComponent(formState.sourceCode)}`;

    await runAction(
      "Vector crosswalk",
      `/terminology/vector/crosswalk?${sourceParams}${targetSystemParams}${targetReleaseParams}${langParam}&limit=${limit}&model=${model}`
    );
  }

  const responsePreview = useMemo(() => {
    if (!lastResult) {
      return "Run an action to inspect the live server response.";
    }

    return JSON.stringify(lastResult.request.responseBody, null, 2);
  }, [lastResult]);

  const resultItems = useMemo(() => {
    const body = lastResult?.request.responseBody;

    if (typeof body !== "object" || body === null || !("items" in body)) {
      return [];
    }

    const items = (body as { items?: unknown }).items;
    return Array.isArray(items) ? items : [];
  }, [lastResult]);

  return (
    <section className="workspace-layout">
      <div className="content-panel workspace-main">
        <div className="workspace-header">
          <div>
            <Link className="icon-button" to="/" aria-label="Back home">
              ←
            </Link>
            <p className="eyebrow">Vector layer</p>
            <h2 className="section-title">Semantic Search Workspace</h2>
            <p className="section-copy">
              Search clinical terminology content by meaning and propose semantic
              crosswalk candidates between SNOMED CT, LOINC and ICD releases.
            </p>
          </div>

          <div className="workspace-meta">
            <span className="pill">Native API</span>
            <span className="pill">Embeddings</span>
          </div>
        </div>

        <div className="tab-row">
          <button
            className={`tab-button ${
              activeTab === "search" ? "tab-button-active" : ""
            }`}
            onClick={() => setActiveTab("search")}
          >
            Semantic Search
          </button>
          <button
            className={`tab-button ${
              activeTab === "crosswalk" ? "tab-button-active" : ""
            }`}
            onClick={() => setActiveTab("crosswalk")}
          >
            Crosswalk
          </button>
        </div>

        <section className="workspace-section workspace-operation">
        <div className="workspace-section-header">
            <div className="workspace-section-heading">
            <span className="workspace-section-step">Step 1</span>
            <h3 className="workspace-section-title">Operation</h3>
            </div>
            <button
            className="section-toggle-button"
            onClick={() => toggleSection("operation")}
            >
            {collapsedSections.operation ? "+" : "−"}
            </button>
        </div>

        {!collapsedSections.operation ? (
            <div className="form-panel workspace-form">
            <h3 className="form-title">
                {activeTab === "search"
                ? "Free-text semantic search"
                : "Semantic crosswalk"}
            </h3>
            <p className="form-copy">
                {activeTab === "search"
                ? "Vectorize a clinical phrase and retrieve the closest terms from selected systems."
                : "Use either free text or a source code to find equivalent candidates in target systems."}
            </p>

            <div className="form">
                {activeTab === "search"
                ? renderSearchFields(formState, updateField, toggleMultiValue)
                : renderCrosswalkFields(formState, updateField, toggleMultiValue)}

                <div className="field-row">
                <div className="field">
                    <label>Limit</label>
                    <input
                    value={formState.limit}
                    onChange={(event) => updateField("limit", event.target.value)}
                    />
                </div>
                <div className="field">
                    <label>Model</label>
                    <input
                    value={formState.model}
                    onChange={(event) => updateField("model", event.target.value)}
                    />
                </div>
                </div>

                {errorMessage ? (
                <p className="error-text">{errorMessage}</p>
                ) : null}

                <div className="button-row">
                <button
                    className="button button-primary"
                    disabled={isRunning}
                    onClick={handleSubmit}
                >
                    {isRunning ? "Running..." : "Run Vector Request"}
                </button>
                <button
                    className="button button-secondary"
                    onClick={() => {
                    setFormState(defaultState);
                    setErrorMessage(null);
                    }}
                >
                    Reset Inputs
                </button>
                </div>
            </div>
            </div>
        ) : null}
        </section>

        <section className="workspace-section workspace-result-section">
            <div className="workspace-section-header">
              <div className="workspace-section-heading">
                <span className="workspace-section-step">Step 2</span>
                <h3 className="workspace-section-title">Result</h3>
              </div>
              <button
                className="section-toggle-button"
                onClick={() => toggleSection("result")}
              >
                {collapsedSections.result ? "+" : "−"}
              </button>
            </div>

            {!collapsedSections.result ? (
              <div className="form-panel workspace-result">
                <h3 className="form-title">
                  {lastResult ? lastResult.label : "Awaiting request"}
                </h3>
                <p className="form-copy">{getSummaryCopy(lastResult?.request.responseBody)}</p>

                {resultItems.length > 0 ? (
                  <div className="vector-result-list">
                    {resultItems.slice(0, 8).map((item, index) => (
                      <VectorResultCard key={index} item={item} />
                    ))}
                  </div>
                ) : (
                  <div className="result-preview">
                    <pre>{responsePreview}</pre>
                  </div>
                )}
              </div>
            ) : null}
        </section>

        <section className="workspace-section workspace-technical">
          <div className="workspace-section-header">
            <div className="workspace-section-heading">
              <span className="workspace-section-step">Step 3</span>
              <h3 className="workspace-section-title">Technical View</h3>
            </div>
            <button
              className="section-toggle-button"
              onClick={() => toggleSection("technical")}
            >
              {collapsedSections.technical ? "+" : "−"}
            </button>
          </div>

          {!collapsedSections.technical ? (
            <div className="form-panel workspace-result request-panel">
              {lastResult ? (
                <div className="request-details">
                  <div className="request-metadata">
                    <span className="pill">HTTP method: {lastResult.request.method}</span>
                    <span className="pill">Status: {lastResult.request.status}</span>
                  </div>
                  <div className="request-block">
                    <pre>{lastResult.request.url}</pre>
                  </div>
                  <div className="request-block">
                    <pre>
                      {JSON.stringify(lastResult.request.requestHeaders, null, 2)}
                    </pre>
                  </div>
                  <div className="request-block">
                    <pre>
                      {JSON.stringify(lastResult.request.responseBody, null, 2)}
                    </pre>
                  </div>
                </div>
              ) : (
                <p className="form-copy">
                  The raw URL, headers and response payload will appear here after
                  you run a vector action.
                </p>
              )}
            </div>
          ) : null}
        </section>
      </div>
    </section>
  );
}

function renderSearchFields(
  formState: VectorFormState,
  updateField: <K extends keyof VectorFormState>(
    field: K,
    value: VectorFormState[K]
  ) => void,
  toggleMultiValue: (
    field: "searchSystemUris" | "targetSystemUris",
    value: string
  ) => void
) {
  return (
    <>
      <div className="field">
        <label>Free text</label>
        <textarea
          className="textarea"
          value={formState.query}
          onChange={(event) => updateField("query", event.target.value)}
          rows={3}
        />
      </div>

      <SystemCheckboxes
        label="Systems"
        selectedValues={formState.searchSystemUris}
        onToggle={(value) => toggleMultiValue("searchSystemUris", value)}
      />

      <div className="field-row">
        <div className="field">
          <label>Release IDs, comma-separated</label>
          <input
            value={formState.searchReleaseIds}
            onChange={(event) =>
              updateField("searchReleaseIds", event.target.value)
            }
            placeholder="SNOMED-ES-20250131, ICD10ES-2026-DX"
          />
        </div>
        <div className="field">
          <label>Language</label>
          <input
            value={formState.searchLang}
            onChange={(event) => updateField("searchLang", event.target.value)}
          />
        </div>
      </div>
    </>
  );
}

function renderCrosswalkFields(
  formState: VectorFormState,
  updateField: <K extends keyof VectorFormState>(
    field: K,
    value: VectorFormState[K]
  ) => void,
  toggleMultiValue: (
    field: "searchSystemUris" | "targetSystemUris",
    value: string
  ) => void
) {
  return (
    <>
      <div className="field">
        <label>Free text source, optional</label>
        <textarea
          className="textarea"
          value={formState.crosswalkQuery}
          onChange={(event) =>
            updateField("crosswalkQuery", event.target.value)
          }
          rows={2}
          placeholder="Leave empty to use source code lookup"
        />
      </div>

      <div className="field-row">
        <div className="field">
          <label>Source system URI</label>
          <input
            value={formState.sourceSystemUri}
            onChange={(event) =>
              updateField("sourceSystemUri", event.target.value)
            }
          />
        </div>
        <div className="field">
          <label>Source release ID</label>
          <input
            value={formState.sourceReleaseId}
            onChange={(event) =>
              updateField("sourceReleaseId", event.target.value)
            }
          />
        </div>
      </div>

      <div className="field">
        <label>Source code</label>
        <input
          value={formState.sourceCode}
          onChange={(event) => updateField("sourceCode", event.target.value)}
        />
      </div>

      <SystemCheckboxes
        label="Target systems"
        selectedValues={formState.targetSystemUris}
        onToggle={(value) => toggleMultiValue("targetSystemUris", value)}
      />

      <div className="field-row">
        <div className="field">
          <label>Target release IDs, comma-separated</label>
          <input
            value={formState.targetReleaseIds}
            onChange={(event) =>
              updateField("targetReleaseIds", event.target.value)
            }
          />
        </div>
        <div className="field">
          <label>Language</label>
          <input
            value={formState.crosswalkLang}
            onChange={(event) =>
              updateField("crosswalkLang", event.target.value)
            }
          />
        </div>
      </div>
    </>
  );
}

function SystemCheckboxes({
  label,
  selectedValues,
  onToggle
}: {
  label: string;
  selectedValues: string[];
  onToggle: (value: string) => void;
}) {
  return (
    <div className="field">
      <label>{label}</label>
      <div className="chip-row">
        {SYSTEM_OPTIONS.map((option) => (
          <button
            key={option.value}
            type="button"
            className={`chip chip-button ${
              selectedValues.includes(option.value) ? "chip-button-active" : ""
            }`}
            onClick={() => onToggle(option.value)}
          >
            {option.label}
          </button>
        ))}
      </div>
    </div>
  );
}

function VectorResultCard({ item }: { item: unknown }) {
  const record =
    typeof item === "object" && item !== null
      ? (item as Record<string, unknown>)
      : {};

  const score = Number(record.score ?? record.Score ?? 0);
  const normalizedScore = Number.isFinite(score)
    ? Math.max(0, Math.min(100, Math.round(score * 100)))
    : 0;

  return (
    <article className="vector-result-card">
      <div className="card-top">
        <div>
          <h3>{String(record.code ?? record.Code ?? "Unknown code")}</h3>
          <p>{String(record.text ?? record.Text ?? "")}</p>
        </div>
        <span className="pill">
          {Number.isFinite(score) ? score.toFixed(4) : "score"}
        </span>
      </div>

      <div className="vector-score">
        <div style={{ width: `${normalizedScore}%` }} />
      </div>

      <div className="card-meta">
        <span className="meta-item">
          System: {String(record.systemUri ?? record.SystemUri ?? "")}
        </span>
        <span className="meta-item">
          Release: {String(record.releaseId ?? record.ReleaseId ?? "")}
        </span>
        <span className="meta-item">
          Lang: {String(record.lang ?? record.Lang ?? "")}
        </span>
      </div>
    </article>
  );
}

function getSummaryCopy(responseBody: unknown): string {
  if (typeof responseBody === "object" && responseBody !== null) {
    const record = responseBody as Record<string, unknown>;

    if (Array.isArray(record.items)) {
      return `The response includes ${record.items.length} vector matches.`;
    }

    if (typeof record.count === "number") {
      return `The response reports ${record.count} vector matches.`;
    }

    return `The response returned ${Object.keys(record).length} top-level fields.`;
  }

  return "Run an action to inspect the live server response.";
}