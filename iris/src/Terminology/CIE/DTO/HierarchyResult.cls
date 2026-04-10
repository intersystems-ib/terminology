Class Terminology.CIE.DTO.HierarchyResult Extends Terminology.CIE.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.CIE.DTO.HierarchyItem;

Storage Default
{
<Data name="HierarchyResultState">
<Subscript>"HierarchyResult"</Subscript>
<Value name="1">
<Value>Count</Value>
</Value>
<Value name="2">
<Value>Items</Value>
</Value>
</Data>
<State>HierarchyResultState</State>
<Type>%Storage.Serial</Type>
}

}
