Class Terminology.Production.Msg.VectorSearchResponse Extends Ens.Response
{

Property Payload As Terminology.Vector.DTO.SearchResult;

Storage Default
{
<Data name="VectorSearchResponseDefaultData">
<Subscript>"VectorSearchResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>VectorSearchResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
