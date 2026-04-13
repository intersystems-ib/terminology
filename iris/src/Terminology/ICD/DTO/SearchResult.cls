Class Terminology.ICD.DTO.SearchResult Extends Terminology.ICD.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.ICD.DTO.SearchItem;

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
