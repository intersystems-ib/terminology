Class Terminology.Core.Trace Extends %RegisteredObject
{

/// Global trace switch. Set ^TSTrace("enabled")=1 to record request traces.
ClassMethod IsEnabled() As %Boolean
{
    Return +$Get(^TSTrace("enabled"))
}

/// Starts one correlated request trace and stores the current request id in a process-private global
/// so deeper layers can append entries without passing the id through every method signature.
ClassMethod StartRequest(pLayer As %String, pOperation As %String, pPayload As %String = "") As %String
{
    If '..IsEnabled() {
        Return ""
    }

    Set reqId = $Increment(^TSTrace("request"))
    Set ^||TSTraceRequestId = reqId
    Set ^||TSTraceRequestStart = $ZHOROLOG

    Set ^TSTrace("req", reqId, "started") = ..Now()
    Set ^TSTrace("req", reqId, "layer") = pLayer
    Set ^TSTrace("req", reqId, "operation") = pOperation
    Set ^TSTrace("req", reqId, "job") = $Job
    Set ^TSTrace("req", reqId, "namespace") = $Namespace

    Do ..Log(pLayer, "request-start", pOperation_" "_pPayload)
    Return reqId
}

ClassMethod EndRequest(pLayer As %String, pMessage As %String = "request-end", pPayload As %String = "") As %Status
{
    If '..IsEnabled() {
        Return $$$OK
    }

    Set reqId = $Get(^||TSTraceRequestId)
    If reqId="" {
        Return $$$OK
    }

    Set elapsedMs = ..ElapsedMilliseconds($Get(^||TSTraceRequestStart))
    Do ..Log(pLayer, pMessage, "elapsedMs="_elapsedMs_" "_pPayload)
    Do ..ClearRequestId()
    Return $$$OK
}

ClassMethod ClearRequestId() As %Status
{
    Kill ^||TSTraceRequestId
    Kill ^||TSTraceRequestStart
    Return $$$OK
}

ClassMethod RestoreRequestContext(pRequest As Terminology.Production.Msg.BaseRequest) As %Status
{
    If '..IsEnabled() {
        Return $$$OK
    }

    If pRequest.TraceId'="" {
        Set ^||TSTraceRequestId = pRequest.TraceId
    }

    If pRequest.TraceStart'="" {
        Set ^||TSTraceRequestStart = pRequest.TraceStart
    }

    Return $$$OK
}

ClassMethod EnsureRequestId() As %String
{
    If '..IsEnabled() {
        Return ""
    }

    /// Internal calls can still emit trace entries even when no explicit request boundary was set.
    Set reqId = $Get(^||TSTraceRequestId)
    If reqId="" {
        Set reqId = ..StartRequest("internal", "implicit")
    }

    Return reqId
}

/// Entries are stored as named subnodes under ^TSTrace("req",reqId,"entry",seq,...) so
/// ZWRITE output is readable and naturally ordered by request and sequence number.
ClassMethod Log(pLayer As %String, pMessage As %String, pPayload As %String = "") As %Status
{
    If '..IsEnabled() {
        Return $$$OK
    }

    Set reqId = ..EnsureRequestId()
    Set seq = $Increment(^TSTrace("req", reqId, "seq"))
    Set ^TSTrace("req", reqId, "entry", seq, "ts") = ..Now()
    Set ^TSTrace("req", reqId, "entry", seq, "job") = $Job
    Set ^TSTrace("req", reqId, "entry", seq, "layer") = pLayer
    Set ^TSTrace("req", reqId, "entry", seq, "message") = ..NormalizeText(pMessage)
    If pPayload'="" {
        Set ^TSTrace("req", reqId, "entry", seq, "payload") = ..NormalizeText(pPayload)
    }
    Return $$$OK
}

/// SQL logging stays text-based for the MVP so every query can be inspected directly from ^TSTrace.
ClassMethod LogSQL(pContext As %String, pSql As %String, ByRef pArgs, pArgCount As %Integer, pElapsedMs As %Numeric = "", pStatus As %String = "OK") As %Status
{
    If '..IsEnabled() {
        Return $$$OK
    }

    Set payload = "status="_pStatus_" elapsedMs="_pElapsedMs_" args="_..SerializeArgs(.pArgs, pArgCount)_" sql="_..NormalizeText(pSql)
    Do ..Log("sql", pContext, payload)
    Return $$$OK
}

ClassMethod LogError(pLayer As %String, pMessage As %String, pPayload As %String = "") As %Status
{
    Return ..Log(pLayer, "error: "_pMessage, pPayload)
}

ClassMethod SerializeArgs(ByRef pArgs, pArgCount As %Integer) As %String [ Private ]
{
    If pArgCount'>0 {
        Return "[]"
    }

    Set text = "["
    For index=1:1:pArgCount {
        If index>1 {
            Set text = text_", "
        }
        Set text = text_""""_..NormalizeText($Get(pArgs(index)))_""""
    }
    Set text = text_"]"
    Return text
}

ClassMethod NormalizeText(pValue As %String = "") As %String [ Private ]
{
    Set text = $Get(pValue)
    Set text = $Translate(text, $Char(13,10,9), "   ")

    If $Length(text)>800 {
        Set text = $Extract(text, 1, 800)_"..."
    }

    Return text
}

ClassMethod ElapsedMilliseconds(pStart As %String) As %Integer
{
    If pStart="" {
        Return 0
    }

    Return ($ZHOROLOG - pStart) * 1000
}

ClassMethod Now() As %String [ Private ]
{
    Return $ZDATETIME($HOROLOG, 3, 1)
}

}
