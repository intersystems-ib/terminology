Class Terminology.CIE.DTO.HierarchyItem Extends Terminology.CIE.DTO.Base
{

Property Code As %String;

Property Description As %String;

Property ParentCode As %String;

Property Depth As %Integer;

Property HierarchyLevel As %Integer;

Storage Default
{
<Data name="HierarchyItemState">
<Subscript>"HierarchyItem"</Subscript>
<Value name="1">
<Value>Code</Value>
</Value>
<Value name="2">
<Value>Description</Value>
</Value>
<Value name="3">
<Value>ParentCode</Value>
</Value>
<Value name="4">
<Value>Depth</Value>
</Value>
<Value name="5">
<Value>HierarchyLevel</Value>
</Value>
</Data>
<State>HierarchyItemState</State>
<Type>%Storage.Serial</Type>
}

}
