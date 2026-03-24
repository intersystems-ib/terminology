Class Terminology.Production.SnomedApi Extends (%CSP.REST, Ens.BusinessService)
{

Parameter HandleCorsRequest = 0;

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter TargetConfigName = "SnomedRepositoryOperation";

Parameter GatewayConfigName = "SnomedGatewayService";

XData UrlMap
{
<Routes>
    <Route Url="/search" Method="GET" Call="Search"/>
    <Route Url="/concepts/:conceptId" Method="GET" Call="GetConcept"/>
    <Route Url="/concepts/:conceptId/children" Method="GET" Call="GetChildren"/>
    <Route Url="/concepts/:conceptId/descendants" Method="GET" Call="GetDescendants"/>
    <Route Url="/concepts/:conceptId/ancestors" Method="GET" Call="GetAncestors"/>
    <Route Url="/concepts/:conceptId/descriptions" Method="GET" Call="GetDescriptions"/>
    <Route Url="/subsumes/:codeA/:codeB" Method="GET" Call="GetSubsumes"/>
    <Route Url="/refsets" Method="GET" Call="GetRefsets"/>
    <Route Url="/refsets/:refsetId/members" Method="GET" Call="GetRefsetMembers"/>
    <Route Url="/validate-code" Method="GET" Call="ValidateCode"/>
</Routes>
}

ClassMethod OnHandleCorsRequest(url As %String) As %Status
{
	set url = %request.GetCgiEnv("HTTP_REFERER")
    set origin = $p(url,"/",1,3) // origin = "http(s)://origin.com:port"

    // here you can check specific origins
    // otherway, it will allow all origins (useful while developing only)

	do %response.SetHeader("Access-Control-Allow-Credentials","true")
	do %response.SetHeader("Access-Control-Allow-Methods","GET,POST,PUT,DELETE,OPTIONS")
	do %response.SetHeader("Access-Control-Allow-Origin",origin)
	do %response.SetHeader("Access-Control-Allow-Headers","Access-Control-Allow-Origin, Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control")
	return $$$OK
}

ClassMethod Search() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedSearchRequest).%New()
        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetConcept(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetConceptRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetChildren(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetChildrenRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetDescendants(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetDescendantsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetAncestors(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetAncestorsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetDescriptions(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetDescriptionsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.ActiveOnly = +$Get(%request.Data("activeOnly",1))
        Set req.TypeId = $Get(%request.Data("typeId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=200
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetSubsumes(codeA As %String, codeB As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetSubsumesRequest).%New()
        Set req.CodeA = codeA
        Set req.CodeB = codeB
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetRefsets() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetRefsetsRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod GetRefsetMembers(refsetId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetRefsetMembersRequest).%New()
        Set req.RefsetId = refsetId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedValidateCodeRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Code = $Get(%request.Data("code",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SendGatewayRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
  set status = ##class(Ens.Director).CreateBusinessService(..#GatewayConfigName, .instance)
  Quit instance.SendRequestSync(..#TargetConfigName, pRequest, .pResponse)
}

ClassMethod WriteDynamicResponse(pPayload As %DynamicAbstractObject) As %Status
{
    Set %response.ContentType = "application/json"
    Write pPayload.%ToJSON()
    Return $$$OK
}

ClassMethod WriteError(pMessage As %String, pHttpCode As %Integer = 500) As %Status
{
    Set %response.Status = pHttpCode
    Set %response.ContentType = "application/json"

    Set obj = {}
    Set obj.error = 1
    Set obj.message = pMessage

    Write obj.%ToJSON()
    Return $$$OK
}

}
