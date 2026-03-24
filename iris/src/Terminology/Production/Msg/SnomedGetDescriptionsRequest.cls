Class Terminology.Production.Msg.SnomedGetDescriptionsRequest Extends Ens.Request
{

Property ConceptId As %String;

Property ReleaseId As %String;

Property Lang As %String;

Property ActiveOnly As %Boolean;

Property TypeId As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedGetDescriptionsRequestDefaultData">
<Subscript>"SnomedGetDescriptionsRequest"</Subscript>
<Value name="1">
<Value>ConceptId</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Lang</Value>
</Value>
<Value name="4">
<Value>ActiveOnly</Value>
</Value>
<Value name="5">
<Value>TypeId</Value>
</Value>
<Value name="6">
<Value>Limit</Value>
</Value>
<Value name="7">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedGetDescriptionsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
