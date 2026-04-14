import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { authenticatedJsonRequest, type RequestRecord } from "../lib/api";
import { useAuth } from "../state/AuthContext";

type ApiMode = "native" | "fhir";
type TabId = "search" | "lookup" | "parts" | "hierarchy" | "validate" | "subsumes" | "valueset";

type RunResult = {
  request: RequestRecord;
  label: string;
};

type LoincFormState = {
  releaseId: string;
  lang: string;
  searchQuery: string;
  loincNum: string;
  hierarchyCode: string;
  hierarchyDirection: "ancestors" | "descendants";
  hierarchyType: string;
  hierarchyMaxDepth: string;
  code: string;
  codeA: string;
  codeB: string;
  valueSetId: string;
  valueSetUrl: string;
  valueSetCount: string;
  valueSetOffset: string;
};

const defaultState: LoincFormState = {
  releaseId: "2.82",
  lang: "es",
  searchQuery: "hemo",
  loincNum: "718-7",
  hierarchyCode: "LP392452-1",
  hierarchyDirection: "descendants",
  hierarchyType: "COMPONENTBYSYSTEM",
  hierarchyMaxDepth: "10",
  code: "718-7",
  codeA: "LP392452-1",
  codeB: "718-7",
  valueSetId: "loinc-group-LG51020-2",
  valueSetUrl: "http://loinc.org/vs/LG51020-2",
  valueSetCount: "10",
  valueSetOffset: "0"
};

const tabDefinitions: Array<{ id: TabId; label: string; modeSupport: "both" | "native" | "fhir" }> = [
  { id: "search", label: "Search", modeSupport: "native" },
  { id: "lookup", label: "Lookup", modeSupport: "both" },
  { id: "parts", label: "Parts", modeSupport: "native" },
  { id: "hierarchy", label: "Hierarchy", modeSupport: "native" },
  { id: "validate", label: "Validate", modeSupport: "both" },
  { id: "subsumes", label: "Subsumes", modeSupport: "both" },
  { id: "valueset", label: "ValueSet", modeSupport: "fhir" }
];

export function LoincWorkspace() {
  const { session } = useAuth();
  const [apiMode, setApiMode] = useState<ApiMode>("native");
  const [activeTab, setActiveTab] = useState<TabId>("search");
  const [formState, setFormState] = useState<LoincFormState>(defaultState);
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

  function updateField<K extends keyof LoincFormState>(field: K, value: LoincFormState[K]) {
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
      const fallbackMessage = error instanceof Error ? error.message : "The LOINC request failed.";
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
          "LOINC search",
          `/terminology/loinc/search?q=${encodeURIComponent(formState.searchQuery)}&releaseId=${encodeURIComponent(formState.releaseId)}&lang=${encodeURIComponent(formState.lang)}&limit=20&offset=0`,
          "application/json"
        );
        return;
      case "lookup":
        if (apiMode === "native") {
          await runAction(
            "LOINC code lookup",
            `/terminology/loinc/codes/${encodeURIComponent(formState.loincNum)}?releaseId=${encodeURIComponent(formState.releaseId)}`,
            "application/json"
          );
          return;
        }

        await runAction(
          "LOINC FHIR lookup",
          `/terminology/fhir/r4/CodeSystem/$lookup?system=${encodeURIComponent("http://loinc.org")}&code=${encodeURIComponent(formState.loincNum)}&displayLanguage=${encodeURIComponent(formState.lang)}`,
          "application/fhir+json"
        );
        return;
      case "parts":
        await runAction(
          "LOINC parts",
          `/terminology/loinc/codes/${encodeURIComponent(formState.loincNum)}/parts?releaseId=${encodeURIComponent(formState.releaseId)}&limit=200&offset=0`,
          "application/json"
        );
        return;
      case "hierarchy":
        await runAction(
          `LOINC ${formState.hierarchyDirection}`,
          `/terminology/loinc/codes/${encodeURIComponent(formState.hierarchyCode)}/${formState.hierarchyDirection}?releaseId=${encodeURIComponent(formState.releaseId)}&hierarchyType=${encodeURIComponent(formState.hierarchyType)}&maxDepth=${encodeURIComponent(formState.hierarchyMaxDepth)}&limit=100&offset=0`,
          "application/json"
        );
        return;
      case "validate":
        if (apiMode === "native") {
          await runAction(
            "LOINC validate code",
            `/terminology/loinc/validate-code?releaseId=${encodeURIComponent(formState.releaseId)}&code=${encodeURIComponent(formState.code)}`,
            "application/json"
          );
          return;
        }

        await runAction(
          "LOINC FHIR validate code",
          `/terminology/fhir/r4/CodeSystem/$validate-code?system=${encodeURIComponent("http://loinc.org")}&code=${encodeURIComponent(formState.code)}`,
          "application/fhir+json"
        );
        return;
      case "subsumes":
        await runAction(
          apiMode === "native" ? "LOINC subsumes via FHIR layer" : "LOINC FHIR subsumes",
          `/terminology/fhir/r4/CodeSystem/$subsumes?system=${encodeURIComponent("http://loinc.org")}&codeA=${encodeURIComponent(formState.codeA)}&codeB=${encodeURIComponent(formState.codeB)}`,
          "application/fhir+json"
        );
        return;
      case "valueset":
        await runAction(
          "LOINC ValueSet expand",
          `/terminology/fhir/r4/ValueSet/$expand?url=${encodeURIComponent(formState.valueSetUrl)}&displayLanguage=${encodeURIComponent(formState.lang)}&count=${encodeURIComponent(formState.valueSetCount)}&offset=${encodeURIComponent(formState.valueSetOffset)}`,
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
              <p className="eyebrow">LOINC Workspace</p>
              <h2 className="section-title">Explore LOINC through native and FHIR terminology APIs.</h2>
              <p className="section-copy">
                Use one workspace to move between search, code lookup, parts, hierarchy navigation, validation,
                subsumption and ValueSet expansion using the example values from the repo docs.
              </p>
            </div>
          </div>
          <div className="workspace-meta">
            <Link className="icon-button" to="/" aria-label="Back home" title="Back home">
              <HomeIcon />
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

        <div className="tab-row" role="tablist" aria-label="LOINC actions">
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
              aria-label={collapsedSections.operation ? "Expand operation" : "Collapse operation"}
              title={collapsedSections.operation ? "Expand operation" : "Collapse operation"}
            >
              {collapsedSections.operation ? <ExpandIcon /> : <CollapseIcon />}
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
              aria-label={collapsedSections.result ? "Expand result" : "Collapse result"}
              title={collapsedSections.result ? "Expand result" : "Collapse result"}
            >
              {collapsedSections.result ? <ExpandIcon /> : <CollapseIcon />}
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
              aria-label={collapsedSections.technical ? "Expand technical view" : "Collapse technical view"}
              title={collapsedSections.technical ? "Expand technical view" : "Collapse technical view"}
            >
              {collapsedSections.technical ? <ExpandIcon /> : <CollapseIcon />}
            </button>
          </div>
          {!collapsedSections.technical ? (
            <section className="content-panel workspace-result">
              <div className="request-panel-top">
                <div>
                  <h3 className="form-title">Request and response</h3>
                  <p className="form-copy">
                    Use this panel during demos to connect the UI action with the exact LOINC API call and payload.
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
                  <p>The raw URL, headers and response payload will appear here after you run a LOINC action.</p>
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
      return "Search LOINC codes through the native endpoint using the example text from the HTTP docs.";
    case "lookup":
      return apiMode === "native"
        ? "Resolve one LOINC code through the native API."
        : "Run the same lookup idea through the FHIR CodeSystem operation.";
    case "parts":
      return "Inspect the parts that make up one LOINC code.";
    case "hierarchy":
      return "Navigate LOINC ancestors or descendants for a selected hierarchy type.";
    case "validate":
      return apiMode === "native"
        ? "Check whether a LOINC code exists in the selected release."
        : "Call the FHIR validate-code operation for the same code.";
    case "subsumes":
      return "Check the parent-child relationship using the FHIR CodeSystem/$subsumes operation.";
    case "valueset":
      return "Expand a LOINC group ValueSet through the FHIR terminology layer.";
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
  if (Array.isArray(responseBody)) {
    return `The response returned ${responseBody.length} top-level items.`;
  }

  if (typeof responseBody === "object" && responseBody !== null) {
    const record = responseBody as Record<string, unknown>;

    if (Array.isArray(record.items)) {
      return `The response includes ${record.items.length} items in the main collection.`;
    }

    if (Array.isArray(record.entry)) {
      return `The response includes ${record.entry.length} FHIR bundle entries.`;
    }

    if (record.resourceType) {
      return `FHIR resource type: ${String(record.resourceType)}.`;
    }

    return `The response returned ${Object.keys(record).length} top-level fields.`;
  }

  return "Run an action to inspect the live server response.";
}

function renderTabFields(
  activeTab: TabId,
  apiMode: ApiMode,
  formState: LoincFormState,
  updateField: <K extends keyof LoincFormState>(field: K, value: LoincFormState[K]) => void
) {
  const baseContextFields = (
    <>
      <div className="field">
        <label htmlFor="loincReleaseId">Release ID</label>
        <input
          id="loincReleaseId"
          value={formState.releaseId}
          onChange={(event) => updateField("releaseId", event.target.value)}
          disabled={apiMode === "fhir"}
        />
      </div>
      <div className="field">
        <label htmlFor="loincLang">Language</label>
        <input id="loincLang" value={formState.lang} onChange={(event) => updateField("lang", event.target.value)} />
      </div>
    </>
  );

  switch (activeTab) {
    case "search":
      return (
        <>
          {baseContextFields}
          <div className="field">
            <label htmlFor="loincSearchQuery">Search text</label>
            <input
              id="loincSearchQuery"
              value={formState.searchQuery}
              onChange={(event) => updateField("searchQuery", event.target.value)}
            />
          </div>
        </>
      );
    case "lookup":
    case "parts":
      return (
        <>
          {baseContextFields}
          <div className="field">
            <label htmlFor="loincNum">LOINC number</label>
            <input
              id="loincNum"
              value={formState.loincNum}
              onChange={(event) => updateField("loincNum", event.target.value)}
            />
          </div>
        </>
      );
    case "hierarchy":
      return (
        <>
          {baseContextFields}
          <div className="field-row">
            <div className="field">
              <label htmlFor="loincHierarchyCode">Code</label>
              <input
                id="loincHierarchyCode"
                value={formState.hierarchyCode}
                onChange={(event) => updateField("hierarchyCode", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="loincHierarchyDirection">Direction</label>
              <select
                id="loincHierarchyDirection"
                className="select"
                value={formState.hierarchyDirection}
                onChange={(event) =>
                  updateField("hierarchyDirection", event.target.value as LoincFormState["hierarchyDirection"])
                }
              >
                <option value="ancestors">Ancestors</option>
                <option value="descendants">Descendants</option>
              </select>
            </div>
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="loincHierarchyType">Hierarchy type</label>
              <input
                id="loincHierarchyType"
                value={formState.hierarchyType}
                onChange={(event) => updateField("hierarchyType", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="loincHierarchyMaxDepth">Max depth</label>
              <input
                id="loincHierarchyMaxDepth"
                value={formState.hierarchyMaxDepth}
                onChange={(event) => updateField("hierarchyMaxDepth", event.target.value)}
              />
            </div>
          </div>
        </>
      );
    case "validate":
      return (
        <>
          {baseContextFields}
          <div className="field">
            <label htmlFor="loincCode">Code</label>
            <input
              id="loincCode"
              value={formState.code}
              onChange={(event) => updateField("code", event.target.value)}
            />
          </div>
        </>
      );
    case "subsumes":
      return (
        <>
          <div className="field">
            <label htmlFor="loincLangSubsumes">Language</label>
            <input
              id="loincLangSubsumes"
              value={formState.lang}
              onChange={(event) => updateField("lang", event.target.value)}
            />
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="loincCodeA">Code A</label>
              <input
                id="loincCodeA"
                value={formState.codeA}
                onChange={(event) => updateField("codeA", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="loincCodeB">Code B</label>
              <input
                id="loincCodeB"
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
            <label htmlFor="loincValueSetId">ValueSet ID</label>
            <input
              id="loincValueSetId"
              value={formState.valueSetId}
              onChange={(event) => updateField("valueSetId", event.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="loincValueSetUrl">ValueSet URL</label>
            <input
              id="loincValueSetUrl"
              value={formState.valueSetUrl}
              onChange={(event) => updateField("valueSetUrl", event.target.value)}
            />
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="loincValueSetCount">Count</label>
              <input
                id="loincValueSetCount"
                value={formState.valueSetCount}
                onChange={(event) => updateField("valueSetCount", event.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="loincValueSetOffset">Offset</label>
              <input
                id="loincValueSetOffset"
                value={formState.valueSetOffset}
                onChange={(event) => updateField("valueSetOffset", event.target.value)}
              />
            </div>
          </div>
          <div className="field">
            <label htmlFor="loincValueSetLang">Display language</label>
            <input
              id="loincValueSetLang"
              value={formState.lang}
              onChange={(event) => updateField("lang", event.target.value)}
            />
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

function HomeIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <path
        d="M4 11.5L12 5l8 6.5M7 10.5V19h10v-8.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function CollapseIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <path
        d="M7 14l5-5 5 5"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ExpandIcon() {
  return (
    <svg viewBox="0 0 24 24" className="workspace-svg-icon">
      <path
        d="M7 10l5 5 5-5"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
