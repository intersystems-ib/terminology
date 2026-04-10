Class Terminology.Production.Msg.CIESearchResponse Extends Ens.Response
{

Property Payload As Terminology.CIE.DTO.SearchResult;

Storage Default
{
<Data name="CIESearchResponseDefaultData">
<Subscript>"CIESearchResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>CIESearchResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
