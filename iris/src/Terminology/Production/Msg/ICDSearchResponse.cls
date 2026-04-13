Class Terminology.Production.Msg.ICDSearchResponse Extends Ens.Response
{

Property Payload As Terminology.ICD.DTO.SearchResult;

Storage Default
{
<Data name="ICDSearchResponseDefaultData">
<Subscript>"ICDSearchResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>ICDSearchResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
