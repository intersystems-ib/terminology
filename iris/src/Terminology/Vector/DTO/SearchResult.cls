Class Terminology.Vector.DTO.SearchResult Extends Terminology.Vector.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.Vector.DTO.SearchItem;

Storage Default
{
<Data name="SearchResultState">
<Subscript>"SearchResult"</Subscript>
<Value name="1">
<Value>Count</Value>
</Value>
<Value name="2">
<Value>Items</Value>
</Value>
</Data>
<State>SearchResultState</State>
<Type>%Storage.Serial</Type>
}

}
