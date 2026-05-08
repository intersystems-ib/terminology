Class Terminology.Production.Msg.SnomedGetIcd10MappingsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property ConceptId As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedGetIcd10MappingsRequestDefaultData">
<Subscript>"SnomedGetIcd10MappingsRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>ConceptId</Value>
</Value>
<Value name="3">
<Value>Limit</Value>
</Value>
<Value name="4">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedGetIcd10MappingsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
