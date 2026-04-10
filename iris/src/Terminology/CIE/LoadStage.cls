Class Terminology.CIE.LoadStage Extends (%Persistent, %Populate)
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Version As %Integer [ Required ];

Property CodeType As %String(MAXLEN = 32) [ Required ];

Property RowNum As %Integer [ Required ];

Property RecordKind As %String(MAXLEN = 16);

// CHAPTER / FAMILY / CODE

Property RawCode As %String(MAXLEN = 64);

Property RawDescription As %String(MAXLEN = 2000);

Property CurrentChapterCode As %String(MAXLEN = 32);

Property CurrentFamilyCode As %String(MAXLEN = 32);

Property NodeFinal As %Boolean [ InitialExpression = 0 ];

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

Index PK On (ReleaseId, Version, CodeType, RowNum) [ Unique ];

Index IXKind On (ReleaseId, Version, CodeType, RecordKind);

Index IXRawCode On (ReleaseId, Version, CodeType, RawCode);

Storage Default
{
<Data name="LoadStageDefaultData">
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
<Value>RowNum</Value>
</Value>
<Value name="6">
<Value>RecordKind</Value>
</Value>
<Value name="7">
<Value>RawCode</Value>
</Value>
<Value name="8">
<Value>RawDescription</Value>
</Value>
<Value name="9">
<Value>CurrentChapterCode</Value>
</Value>
<Value name="10">
<Value>CurrentFamilyCode</Value>
</Value>
<Value name="11">
<Value>NodeFinal</Value>
</Value>
<Value name="12">
<Value>Manifestation</Value>
</Value>
<Value name="13">
<Value>Perinatal</Value>
</Value>
<Value name="14">
<Value>Pediatric</Value>
</Value>
<Value name="15">
<Value>Obstetric</Value>
</Value>
<Value name="16">
<Value>Adult</Value>
</Value>
<Value name="17">
<Value>Female</Value>
</Value>
<Value name="18">
<Value>Male</Value>
</Value>
<Value name="19">
<Value>PoaExempt</Value>
</Value>
<Value name="20">
<Value>DpNotPrincipal</Value>
</Value>
<Value name="21">
<Value>Vcdp</Value>
</Value>
</Data>
<DataLocation>^Terminology.CIE.LoadStageD</DataLocation>
<DefaultData>LoadStageDefaultData</DefaultData>
<IdLocation>^Terminology.CIE.LoadStageD</IdLocation>
<IndexLocation>^Terminology.CIE.LoadStageI</IndexLocation>
<StreamLocation>^Terminology.CIE.LoadStageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
