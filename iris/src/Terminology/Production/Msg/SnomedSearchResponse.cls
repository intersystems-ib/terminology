Class Terminology.Production.Msg.SnomedSearchResponse Extends Ens.Response
{

Property Payload As Terminology.Snomed.DTO.SearchResult;

Storage Default
{
<Data name="SnomedSearchResponseDefaultData">
<Subscript>"SnomedSearchResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>SnomedSearchResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
