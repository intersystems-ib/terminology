import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { authenticatedJsonRequest, type RequestRecord } from "../lib/api";
import { useAuth } from "../state/AuthContext";

type ApiMode = "native" | "fhir";
type TabId = "search" | "lookup" | "hierarchy" | "validate" | "subsumes" | "valueset";

type RunResult = {
  request: RequestRecord;
  label: string;
};

type IcdFormState = {
  releaseId: string;
  version: string;
  codeType: "DIAGNOSIS" | "PROCEDURE";
  searchQuery: string;
  code: string;
  hierarchyCode: string;
  hierarchyDirection: "ancestors" | "descendants" | "children";
  includeSelf: "0" | "1";
  maxDepth: string;
  codeA: string;
  codeB: string;
  valueSetId: string;
  valueSetUrl: string;
  valueSetCount: string;
  valueSetOffset: string;
};

const defaultState: IcdFormState = {
  releaseId: "ICD-10-ES 2026",
  version: "10",
  codeType: "DIAGNOSIS",
  searchQuery: "fiebre",
  code: "A01.0",
  hierarchyCode: "A01",
  hierarchyDirection: "descendants",
  includeSelf: "0",
  maxDepth: "10",
  codeA: "A01",
  codeB: "A01.0",
  valueSetId: "icd-family-A00-A09",
  valueSetUrl: "urn:iris:terminology:valueset:icd:family:A00-A09",
  valueSetCount: "10",
  valueSetOffset: "0"
};

const tabDefinitions: Array<{ id: TabId; label: string; modeSupport: "both" | "native" | "fhir" }> = [
  { id: "search", label: "Search", modeSupport: "native" },
  { id: "lookup", label: "Lookup", modeSupport: "both" },
  { id: "hierarchy", label: "Hierarchy", modeSupport: "native" },
  { id: "validate", label: "Validate", modeSupport: "both" },
  { id: "subsumes", label: "Subsumes", modeSupport: "both" },
  { id: "valueset", label: "ValueSet", modeSupport: "fhir" }
];

export function IcdWorkspace() {
  const { session } = useAuth();
  const [apiMode, setApiMode] = useState<ApiMode>("native");
  const [activeTab, setActiveTab] = useState<TabId>("search");
  const [formState, setFormState] = useState<IcdFormState>(defaultState);
  const [collapsedSections, setCollapsedSections] = useState({
    operation: false,
    result: false,
    technical: false
  });
  const [isRunning, setIsRunning] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [lastResult, setLastResult] = useState<RunResult | null>(null);

  const availableTabs = useMemo(
    () => tabDefinitions.filter((tab) => tab.modeSupport === "both" || tab.modeSupport === apiMode),
    [apiMode]
  );

  function updateField<K extends keyof IcdFormState>(field: K, value: IcdFormState[K]) {
    setFormState((current) => ({
      ...current,
      [field]: value
    }));
  }

  function switchMode(nextMode: ApiMode) {
    setApiMode(nextMode);
    const supportedTabs = tabDefinitions.filter((tab) => tab.modeSupport === "both" || tab.modeSupport === nextMode);
    if (!supportedTabs.some((tab) => tab.id === activeTab)) {
      setActiveTab(supportedTabs[0].id);
    }
  }

  function toggleSection(section: keyof typeof collapsedSections) {
    setCollapsedSections((current) => ({
      ...current,
      [section]: !current[section]
    }));
  }

  async function runAction(label: string, path: string, accept: string) {
    if (!session) {
      setErrorMessage("The current session is missing. Please log in again.");
      return;
    }

    setIsRunning(true);
    setErrorMessage(null);

    try {
      const request = await authenticatedJsonRequest(session, path, accept);
      setLastResult({ request, label });
    } catch (error) {
      const fallbackMessage = error instanceof Error ? error.message : "The ICD request failed.";
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
    switch (activeTab) {
      case "search":
        await runAction(
          "ICD search",
          `/terminology/icd/search?q=${encodeURIComponent(formState.searchQuery)}&releaseId=${encodeURIComponent(formState.releaseId)}&version=${encodeURIComponent(formState.version)}&codeType=${encodeURIComponent(formState.codeType)}&limit=20&offset=0`,
          "application/json"
        );
        return;
      case "lookup":
        if (apiMode === "native") {
          await runAction(
            "ICD code lookup",
            `/terminology/icd/codes/${encodeURIComponent(formState.code)}?releaseId=${encodeURIComponent(formState.releaseId)}&version=${encodeURIComponent(formState.version)}&codeType=${encodeURIComponent(formState.codeType)}`,
            "application/json"
          );
          return;
        }

        await runAction(
          "ICD FHIR lookup",
          `/terminology/fhir/r4/CodeSystem/$lookup?system=${encodeURIComponent("http://id.who.int/icd/release/10")}&code=${encodeURIComponent(formState.code)}`,
          "application/fhir+json"
        );
        return;
      case "hierarchy":
        await runAction(
          `ICD ${formState.hierarchyDirection}`,
          `/terminology/icd/codes/${encodeURIComponent(formState.hierarchyCode)}/${formState.hierarchyDirection}?releaseId=${encodeURIComponent(formState.releaseId)}&version=${encodeURIComponent(formState.version)}&codeType=${encodeURIComponent(formState.codeType)}&includeSelf=${encodeURIComponent(formState.includeSelf)}&maxDepth=${encodeURIComponent(formState.maxDepth)}&limit=100&offset=0`,
          "application/json"
        );
        return;
      case "validate":
        if (apiMode === "native") {
          await runAction(
            "ICD validate code",
            `/terminology/icd/validate-code?releaseId=${encodeURIComponent(formState.releaseId)}&version=${encodeURIComponent(formState.version)}&codeType=${encodeURIComponent(formState.codeType)}&code=${encodeURIComponent(formState.code)}`,
            "application/json"
          );
          return;
        }

        await runAction(
          "ICD FHIR validate code",
          `/terminology/fhir/r4/CodeSystem/$validate-code?system=${encodeURIComponent("http://id.who.int/icd/release/10")}&code=${encodeURIComponent(formState.code)}`,
          "application/fhir+json"
        );
        return;
      case "subsumes":
        if (apiMode === "native") {
          await runAction(
            "ICD subsumes via FHIR layer",
            `/terminology/fhir/r4/CodeSystem/$subsumes?system=${encodeURIComponent("http://id.who.int/icd/release/10")}&codeA=${encodeURIComponent(formState.codeA)}&codeB=${encodeURIComponent(formState.codeB)}`,
            "application/fhir+json"
          );
          return;
        }

        await runAction(
          "ICD FHIR subsumes",
          `/terminology/fhir/r4/CodeSystem/$subsumes?system=${encodeURIComponent("http://id.who.int/icd/release/10")}&codeA=${encodeURIComponent(formState.codeA)}&codeB=${encodeURIComponent(formState.codeB)}`,
          "application/fhir+json"
        );
        return;
      case "valueset":
        await runAction(
          "ICD ValueSet expand",
          `/terminology/fhir/r4/ValueSet/$expand?url=${encodeURIComponent(formState.valueSetUrl)}&count=${encodeURIComponent(formState.valueSetCount)}&offset=${encodeURIComponent(formState.valueSetOffset)}`,
          "application/fhir+json"
        );
        return;
      default:
        return;
    }
  }

  const responsePreview = useMemo(() => {
    if (!lastResult) {
      return "Run an action to inspect the live server response.";
    }

    return JSON.stringify(lastResult.request.responseBody, null, 2);
  }, [lastResult]);

  return (
    <main className="workspace-layout">
      <section className="content-panel workspace-main">
        <div className="workspace-header">
          <div className="workspace-heading">
            <div>
              <p className="eyebrow">ICD Workspace</p>
              <h2 className="section-title">Explore ICD through native and FHIR terminology APIs.</h2>
              <p className="section-copy">
                Switch between diagnosis and procedure views, navigate hierarchy behavior, validate codes, compare
                subsumption, and expand family-backed ValueSets from one demo workspace.
              </p>
            </div>
          </div>
          <div className="workspace-meta">
            <Link className="button button-secondary" to="/">
              Back Home
            </Link>
            <span className="pill">Release {formState.releaseId}</span>
            <span className="pill">FHIR + Native</span>
          </div>
        </div>

        <div className="mode-toggle" role="tablist" aria-label="API mode">
          <button
            type="button"
            className={`mode-toggle-button ${apiMode === "native" ? "mode-toggle-button-active" : ""}`}
            onClick={() => switchMode("native")}
          >
            Native API
          </button>
          <button
            type="button"
            className={`mode-toggle-button ${apiMode === "fhir" ? "mode-toggle-button-active" : ""}`}
            onClick={() => switchMode("fhir")}
          >
            FHIR API
          </button>
        </div>

        <div className="tab-row" role="tablist" aria-label="ICD actions">
          {availableTabs.map((tab) => (
            <button
              key={tab.id}
              type="button"
              className={`tab-button ${activeTab === tab.id ? "tab-button-active" : ""}`}
              onClick={() => setActiveTab(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>

        <section className="workspace-section workspace-operation">
          <div className="workspace-section-header">
            <div className="workspace-section-heading">
              <p className="workspace-section-step">Step 1</p>
              <span className="workspace-section-icon" aria-hidden="true">
                <OperationIcon />
              </span>
              <h3 className="workspace-section-title">Operation</h3>
            </div>
            <button
              type="button"
              className="section-toggle-button"
              onClick={() => toggleSection("operation")}
              aria-expanded={!collapsedSections.operation}
            >
              {collapsedSections.operation ? "Expand" : "Collapse"}
            </button>
          </div>
          {!collapsedSections.operation ? (
            <section className="form-panel workspace-form">
              <h3 className="form-title">{getActionTitle(activeTab, apiMode)}</h3>
              <p className="form-copy">{getActionCopy(activeTab, apiMode)}</p>

              <div className="form">
                {renderTabFields(activeTab, apiMode, formState, updateField)}
                {errorMessage ? <p className="error-text">{errorMessage}</p> : null}

                <div className="button-row">
                  <button className="button button-primary" type="button" disabled={isRunning} onClick={handleSubmit}>
                    {isRunning ? "Running..." : getSubmitLabel(activeTab)}
                  </button>
                  <button
                    className="button button-secondary"
                    type="button"
                    onClick={() => {
                      setFormState(defaultState);
                      setErrorMessage(null);
                    }}
                  >
                    Reset Inputs
                  </button>
                </div>
              </div>
            </section>
          ) : null}
        </section>

        <section className="workspace-section workspace-result-section">
          <div className="workspace-section-header">
            <div className="workspace-section-heading">
              <p className="workspace-section-step">Step 2</p>
              <span className="workspace-section-icon" aria-hidden="true">
                <ResultIcon />
              </span>
              <h3 className="workspace-section-title">Result</h3>
            </div>
            <button
              type="button"
              className="section-toggle-button"
              onClick={() => toggleSection("result")}
              aria-expanded={!collapsedSections.result}
            >
              {collapsedSections.result ? "Expand" : "Collapse"}
            </button>
          </div>
          {!collapsedSections.result ? (
            <section className="content-panel workspace-result">
              <h3 className="form-title">{lastResult ? lastResult.label : "Awaiting request"}</h3>
              <p className="form-copy">{getSummaryCopy(lastResult?.request.responseBody)}</p>

              <div className="result-preview">
                <pre>{responsePreview}</pre>
              </div>
            </section>
          ) : null}
        </section>

        <section className="workspace-section workspace-technical">
          <div className="workspace-section-header">
            <div className="workspace-section-heading">
              <p className="workspace-section-step">Step 3</p>
              <span className="workspace-section-icon" aria-hidden="true">
                <TechnicalIcon />
              </span>
              <h3 className="workspace-section-title">Technical View</h3>
            </div>
            <button
              type="button"
              className="section-toggle-button"
              onClick={() => toggleSection("technical")}
              aria-expanded={!collapsedSections.technical}
            >
              {collapsedSections.technical ? "Expand" : "Collapse"}
            </button>
          </div>
          {!collapsedSections.technical ? (
            <section className="content-panel workspace-result">
              <div className="request-panel-top">
                <div>
                  <h3 className="form-title">Request and response</h3>
                  <p className="form-copy">
                    Use this panel during demos to connect the UI action with the exact ICD API call and payload.
                  </p>
                </div>
              </div>

              {lastResult ? (
                <div className="request-details">
                  <div className="request-metadata">
                    <div className="meta-item">HTTP method: {lastResult.request.method}</div>
                    <div className="meta-item">Status: {lastResult.request.status}</div>
                    <div className="meta-item">URL: {lastResult.request.url}</div>
                  </div>

                  <div className="request-block">
                    <strong>Request headers</strong>
                    <pre>{JSON.stringify(lastResult.request.requestHeaders, null, 2)}</pre>
                  </div>

                  <div className="request-block">
                    <strong>Response JSON</strong>
                    <pre>{JSON.stringify(lastResult.request.responseBody, null, 2)}</pre>
                  </div>
                </div>
              ) : (
                <div className="placeholder">
                  <strong>No request yet</strong>
                  <p>The raw URL, headers and response payload will appear here after you run an ICD action.</p>
                </div>
              )}
            </section>
          ) : null}
        </section>
      </section>
    </main>
  );
}

function getActionTitle(activeTab: TabId, apiMode: ApiMode): string {
  if (activeTab === "lookup" && apiMode === "fhir") return "FHIR CodeSystem lookup";
  if (activeTab === "validate" && apiMode === "fhir") return "FHIR validate-code";
  if (activeTab === "subsumes") return "FHIR subsumes";
  if (activeTab === "valueset") return "FHIR ValueSet expansion";
  return `Native ${activeTab}`;
}

function getActionCopy(activeTab: TabId, apiMode: ApiMode): string {
  switch (activeTab) {
    case "search":
      return "Search ICD codes with release, version and code type context from the native endpoint.";
    case "lookup":
      return apiMode === "native"
        ? "Resolve one ICD code through the native API."
        : "Run the same lookup idea through the FHIR CodeSystem operation.";
    case "hierarchy":
      return "Navigate ancestors, descendants or children while controlling include-self and max-depth behavior.";
    case "validate":
      return apiMode === "native"
        ? "Check whether an ICD code exists in the selected release and code type."
        : "Call the FHIR validate-code operation for the same code.";
    case "subsumes":
      return "Compare two ICD codes using the shared FHIR CodeSystem/$subsumes operation.";
    case "valueset":
      return "Expand an ICD family-backed ValueSet through the FHIR terminology layer.";
  }
}

function getSubmitLabel(activeTab: TabId): string {
  if (activeTab === "valueset") return "Expand ValueSet";
  if (activeTab === "validate") return "Validate Code";
  if (activeTab === "subsumes") return "Check Subsumption";
  if (activeTab === "lookup") return "Run Lookup";
  return "Run Request";
}

function getSummaryCopy(responseBody: unknown): string {
  if (Array.isArray(responseBody)) return `The response returned ${responseBody.length} top-level items.`;

  if (typeof responseBody === "object" && responseBody !== null) {
    const record = responseBody as Record<string, unknown>;
    if (Array.isArray(record.items)) return `The response includes ${record.items.length} items in the main collection.`;
    if (Array.isArray(record.entry)) return `The response includes ${record.entry.length} FHIR bundle entries.`;
    if (record.resourceType) return `FHIR resource type: ${String(record.resourceType)}.`;
    return `The response returned ${Object.keys(record).length} top-level fields.`;
  }

  return "Run an action to inspect the live server response.";
}

function renderTabFields(
  activeTab: TabId,
  apiMode: ApiMode,
  formState: IcdFormState,
  updateField: <K extends keyof IcdFormState>(field: K, value: IcdFormState[K]) => void
) {
  const baseContextFields = (
    <>
      <div className="field">
        <label htmlFor="icdReleaseId">Release ID</label>
        <input
          id="icdReleaseId"
          value={formState.releaseId}
          onChange={(event) => updateField("releaseId", event.target.value)}
          disabled={apiMode === "fhir"}
        />
      </div>
      <div className="field-row">
        <div className="field">
          <label htmlFor="icdVersion">Version</label>
          <input
            id="icdVersion"
            value={formState.version}
            onChange={(event) => updateField("version", event.target.value)}
            disabled={apiMode === "fhir"}
          />
        </div>
        <div className="field">
          <label htmlFor="icdCodeType">Code type</label>
          <select
            id="icdCodeType"
            className="select"
            value={formState.codeType}
            onChange={(event) => updateField("codeType", event.target.value as IcdFormState["codeType"])}
            disabled={apiMode === "fhir"}
          >
            <option value="DIAGNOSIS">Diagnosis</option>
            <option value="PROCEDURE">Procedure</option>
          </select>
        </div>
      </div>
    </>
  );

  switch (activeTab) {
    case "search":
      return (
        <>
          {baseContextFields}
          <div className="field">
            <label htmlFor="icdSearchQuery">Search text</label>
            <input
              id="icdSearchQuery"
              value={formState.searchQuery}
              onChange={(event) => updateField("searchQuery", event.target.value)}
            />
          </div>
        </>
      );
    case "lookup":
    case "validate":
      return (
        <>
          {baseContextFields}
          <div className="field">
            <label htmlFor="icdCode">Code</label>
            <input id="icdCode" value={formState.code} onChange={(event) => updateField("code", event.target.value)} />
          </div>
        </>
      );
    case "hierarchy":
      return (
        <>
          {baseContextFields}
          <div className="field-row">
            <div className="field">
              <label htmlFor="icdHierarchyCode">Code</label>
              <input
                id="icdHierarchyCode"
                value={formState.hierarchyCode}
                onChange={(event) => updateField("hierarchyCode", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="icdHierarchyDirection">Direction</label>
              <select
                id="icdHierarchyDirection"
                className="select"
                value={formState.hierarchyDirection}
                onChange={(event) =>
                  updateField("hierarchyDirection", event.target.value as IcdFormState["hierarchyDirection"])
                }
              >
                <option value="ancestors">Ancestors</option>
                <option value="descendants">Descendants</option>
                <option value="children">Children</option>
              </select>
            </div>
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="icdIncludeSelf">Include self</label>
              <select
                id="icdIncludeSelf"
                className="select"
                value={formState.includeSelf}
                onChange={(event) => updateField("includeSelf", event.target.value as IcdFormState["includeSelf"])}
              >
                <option value="0">No</option>
                <option value="1">Yes</option>
              </select>
            </div>
            <div className="field">
              <label htmlFor="icdMaxDepth">Max depth</label>
              <input
                id="icdMaxDepth"
                value={formState.maxDepth}
                onChange={(event) => updateField("maxDepth", event.target.value)}
              />
            </div>
          </div>
        </>
      );
    case "subsumes":
      return (
        <>
          <div className="field-row">
            <div className="field">
              <label htmlFor="icdCodeA">Code A</label>
              <input
                id="icdCodeA"
                value={formState.codeA}
                onChange={(event) => updateField("codeA", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="icdCodeB">Code B</label>
              <input
                id="icdCodeB"
                value={formState.codeB}
                onChange={(event) => updateField("codeB", event.target.value)}
              />
            </div>
          </div>
        </>
      );
    case "valueset":
      return (
        <>
          <div className="field">
            <label htmlFor="icdValueSetId">ValueSet ID</label>
            <input
              id="icdValueSetId"
              value={formState.valueSetId}
              onChange={(event) => updateField("valueSetId", event.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="icdValueSetUrl">ValueSet URL</label>
            <input
              id="icdValueSetUrl"
              value={formState.valueSetUrl}
              onChange={(event) => updateField("valueSetUrl", event.target.value)}
            />
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="icdValueSetCount">Count</label>
              <input
                id="icdValueSetCount"
                value={formState.valueSetCount}
                onChange={(event) => updateField("valueSetCount", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="icdValueSetOffset">Offset</label>
              <input
                id="icdValueSetOffset"
                value={formState.valueSetOffset}
                onChange={(event) => updateField("valueSetOffset", event.target.value)}
              />
            </div>
          </div>
        </>
      );
  }
}

function OperationIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <circle cx="12" cy="12" r="9" fill="currentColor" opacity="0.12" />
      <path
        d="M8 12h8M13 7l5 5-5 5"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ResultIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <rect x="4" y="5" width="16" height="14" rx="4" fill="currentColor" opacity="0.12" />
      <path
        d="M8 12l2.5 2.5L16 9"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function TechnicalIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <rect x="4" y="5" width="16" height="14" rx="4" fill="currentColor" opacity="0.12" />
      <path
        d="M10 9l-3 3 3 3M14 9l3 3-3 3"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
