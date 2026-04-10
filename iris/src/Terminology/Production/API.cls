Class Terminology.Production.API Extends (%CSP.REST, Ens.BusinessService)
{

Parameter HandleCorsRequest = 0;

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter LoincTargetConfigName = "LoincRepositoryOperation";

Parameter SnomedTargetConfigName = "SnomedRepositoryOperation";

Parameter SnomedGatewayConfigName = "SnomedGatewayService";

Parameter LoincGatewayConfigName = "LoincGatewayService";

Parameter CIETargetConfigName = "CIERepositoryOperation";

Parameter CIEGatewayConfigName = "CIEGatewayService";

XData UrlMap
{
<Routes>
    <Route Url="/snomed/search" Method="GET" Call="SnomedSearch"/>
    <Route Url="/snomed/concepts/:conceptId" Method="GET" Call="SnomedGetConcept"/>
    <Route Url="/snomed/concepts/:conceptId/children" Method="GET" Call="SnomedGetChildren"/>
    <Route Url="/snomed/concepts/:conceptId/descendants" Method="GET" Call="SnomedGetDescendants"/>
    <Route Url="/snomed/concepts/:conceptId/ancestors" Method="GET" Call="SnomedGetAncestors"/>
    <Route Url="/snomed/concepts/:conceptId/descriptions" Method="GET" Call="SnomedGetDescriptions"/>
    <Route Url="/snomed/subsumes/:codeA/:codeB" Method="GET" Call="SnomedGetSubsumes"/>
    <Route Url="/snomed/refsets" Method="GET" Call="SnomedGetRefsets"/>
    <Route Url="/snomed/refsets/:refsetId/members" Method="GET" Call="SnomedGetRefsetMembers"/>
    <Route Url="/snomed/validate-code" Method="GET" Call="SnomedValidateCode"/>
    <Route Url="/loinc/search" Method="GET" Call="LoincSearch"/>
    <Route Url="/loinc/codes/:loincNum" Method="GET" Call="LoincGetCode"/>
    <Route Url="/loinc/codes/:loincNum/displays" Method="GET" Call="LoincGetDisplays"/>
    <Route Url="/loinc/codes/:loincNum/parts" Method="GET" Call="LoincGetParts"/>
    <Route Url="/loinc/codes/:loincNum/ancestors" Method="GET" Call="LoincGetAncestors"/>
    <Route Url="/loinc/codes/:loincNum/descendants" Method="GET" Call="LoincGetDescendants"/>
    <Route Url="/loinc/groups" Method="GET" Call="LoincGetGroups"/>
    <Route Url="/loinc/groups/:groupId/members" Method="GET" Call="LoincGetGroupMembers"/>
    <Route Url="/loinc/validate-code" Method="GET" Call="LoincValidateCode"/>
    <Route Url="/cie/search" Method="GET" Call="CIESearch"/>
    <Route Url="/cie/codes/:code" Method="GET" Call="CIEGetCode"/>
    <Route Url="/cie/codes/:code/children" Method="GET" Call="CIEGetChildren"/>
    <Route Url="/cie/codes/:code/descendants" Method="GET" Call="CIEGetDescendants"/>
    <Route Url="/cie/codes/:code/ancestors" Method="GET" Call="CIEGetAncestors"/>

<Route Url="/cie/families" Method="GET" Call="CIEGetFamilies"/>

<Route Url="/cie/validate-code" Method="GET" Call="CIEValidateCode"/>
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

ClassMethod SnomedSearch() As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetConcept(conceptId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetChildren(conceptId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetDescendants(conceptId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetAncestors(conceptId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetDescriptions(conceptId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetSubsumes(codeA As %String, codeB As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetRefsets() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetRefsetsRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedGetRefsetMembers(refsetId As %String) As %Status
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
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod SnomedValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedValidateCodeRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Code = $Get(%request.Data("code",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
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

ClassMethod LoincSearch() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincSearchRequest).%New()
        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetCode(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetCodeRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetDisplays(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetDisplaysRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetParts(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetPartsRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=200
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetAncestors(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetAncestorsRequest).%New()
        Set req.Code = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.HierarchyType = $Get(%request.Data("hierarchyType",1))
        If req.HierarchyType="" Set req.HierarchyType="COMPONENTBYSYSTEM"
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetDescendants(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetDescendantsRequest).%New()
        Set req.Code = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.HierarchyType = $Get(%request.Data("hierarchyType",1))
        If req.HierarchyType="" Set req.HierarchyType="COMPONENTBYSYSTEM"
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetGroups() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetGroupsRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincGetGroupMembers(groupId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetGroupMembersRequest).%New()
        Set req.GroupId = groupId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod LoincValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincValidateCodeRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Code = $Get(%request.Data("code",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
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

ClassMethod CIESearch() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIESearchRequest).%New()

        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEGetCode(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEGetCodeRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEGetChildren(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEGetChildrenRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEGetDescendants(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEGetDescendantsRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEGetAncestors(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEGetAncestorsRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEGetFamilies() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEGetFamiliesRequest).%New()

        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod CIEValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.CIEValidateCodeRequest).%New()

        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))
        Set req.Code = $Get(%request.Data("code",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#CIEGatewayConfigName, ..#CIETargetConfigName)

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

ClassMethod SendGatewayRequest(pRequest As Ens.Request, Output pResponse As Ens.Response, tGatewayName As %String, tTargetName As %String) As %Status
{
  set status = ##class(Ens.Director).CreateBusinessService(tGatewayName, .instance)
  Quit instance.SendRequestSync(tTargetName, pRequest, .pResponse)
}

ClassMethod WriteDynamicResponse(pPayload As %JSON.Adaptor) As %Status
{
    Set %response.ContentType = "application/json"
    do pPayload.%JSONExport()
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
