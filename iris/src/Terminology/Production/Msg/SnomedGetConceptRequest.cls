Class Terminology.Production.Msg.SnomedGetConceptRequest Extends Ens.Request
{

Property ConceptId As %String;

Property ReleaseId As %String;

Property Lang As %String;

Property Dialect As %String;

Storage Default
{
<Data name="SnomedGetConceptRequestDefaultData">
<Subscript>"SnomedGetConceptRequest"</Subscript>
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
<Value>Dialect</Value>
</Value>
</Data>
<DefaultData>SnomedGetConceptRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
