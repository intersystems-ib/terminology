Class Terminology.CIE.Code Extends (%Persistent, %Populate, %JSON.Adaptor)
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Version As %Integer [ Required ];

Property CodeType As %String(MAXLEN = 32) [ Required ];

// DIAGNOSIS / PROCEDURE

Property Code As %String(MAXLEN = 32) [ Required ];

Property Description As %String(MAXLEN = 2000);

Property DescriptionNorm As %String(MAXLEN = 2000);

Property ParentCode As %String(MAXLEN = 32);

Property ChapterCode As %String(MAXLEN = 32);

Property FamilyCode As %String(MAXLEN = 32);

Property HierarchyLevel As %Integer;

Property NodeFinal As %Boolean [ InitialExpression = 0 ];

Property Active As %Boolean [ InitialExpression = 1 ];

Property Manifestation As %Boolean [ InitialExpression = 0 ];

Property Perinatal As %Boolean [ InitialExpression = 0 ];

Property Pediatric As %Boolean [ InitialExpression = 0 ];

Property Obstetric As %Boolean [ InitialExpression = 0 ];

Property Adult As %Boolean [ InitialExpression = 0 ];

Property Female As %Boolean [ InitialExpression = 0 ];

Property Male As %Boolean [ InitialExpression = 0 ];

Property PoaExempt As %Boolean [ InitialExpression = 0 ];

Property DpNotPrincipal As %Boolean [ InitialExpression = 0 ];

Property Vcdp As %Boolean [ InitialExpression = 0 ];

Index PK On (ReleaseId, Version, CodeType, Code) [ Unique ];

Index IXParent On (ReleaseId, Version, CodeType, ParentCode);

Index IXFamily On (ReleaseId, Version, CodeType, FamilyCode);

Index IXChapter On (ReleaseId, Version, CodeType, ChapterCode);

Index IXDescriptionNormCIE On (DescriptionNorm) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Storage Default
{
<Data name="CodeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Version</Value>
</Value>
<Value name="4">
<Value>CodeType</Value>
</Value>
<Value name="5">
<Value>Code</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>DescriptionNorm</Value>
</Value>
<Value name="8">
<Value>ParentCode</Value>
</Value>
<Value name="9">
<Value>ChapterCode</Value>
</Value>
<Value name="10">
<Value>FamilyCode</Value>
</Value>
<Value name="11">
<Value>HierarchyLevel</Value>
</Value>
<Value name="12">
<Value>NodeFinal</Value>
</Value>
<Value name="13">
<Value>Active</Value>
</Value>
<Value name="14">
<Value>Manifestation</Value>
</Value>
<Value name="15">
<Value>Perinatal</Value>
</Value>
<Value name="16">
<Value>Pediatric</Value>
</Value>
<Value name="17">
<Value>Obstetric</Value>
</Value>
<Value name="18">
<Value>Adult</Value>
</Value>
<Value name="19">
<Value>Female</Value>
</Value>
<Value name="20">
<Value>Male</Value>
</Value>
<Value name="21">
<Value>PoaExempt</Value>
</Value>
<Value name="22">
<Value>DpNotPrincipal</Value>
</Value>
<Value name="23">
<Value>Vcdp</Value>
</Value>
</Data>
<DataLocation>^Terminology.CIE.CodeD</DataLocation>
<DefaultData>CodeDefaultData</DefaultData>
<IdLocation>^Terminology.CIE.CodeD</IdLocation>
<IndexLocation>^Terminology.CIE.CodeI</IndexLocation>
<StreamLocation>^Terminology.CIE.CodeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
