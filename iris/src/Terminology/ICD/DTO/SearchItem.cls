Class Terminology.ICD.DTO.SearchItem Extends Terminology.ICD.DTO.Base
{

Property Code As %String;

Property Description As %String;

Property Version As %Integer;

Property CodeType As %String;

Property FamilyCode As %String;

Property ChapterCode As %String;

Property ParentCode As %String;

Property HierarchyLevel As %Integer;

Storage Default
{
<Data name="SearchItemState">
<Subscript>"SearchItem"</Subscript>
<Value name="1">
<Value>Code</Value>
</Value>
<Value name="2">
<Value>Description</Value>
</Value>
<Value name="3">
<Value>Version</Value>
</Value>
<Value name="4">
<Value>CodeType</Value>
</Value>
<Value name="5">
<Value>FamilyCode</Value>
</Value>
<Value name="6">
<Value>ChapterCode</Value>
</Value>
<Value name="7">
<Value>ParentCode</Value>
</Value>
<Value name="8">
<Value>HierarchyLevel</Value>
</Value>
</Data>
<State>SearchItemState</State>
<Type>%Storage.Serial</Type>
}

}
