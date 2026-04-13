Class Terminology.ICD.DTO.FamilyItem Extends Terminology.ICD.DTO.Base
{

Property FamilyCode As %String;

Property Description As %String;

Property ChapterCode As %String;

Property RangeStart As %String;

Property RangeEnd As %String;

Storage Default
{
<Data name="FamilyItemState">
<Subscript>"FamilyItem"</Subscript>
<Value name="1">
<Value>FamilyCode</Value>
</Value>
<Value name="2">
<Value>Description</Value>
</Value>
<Value name="3">
<Value>ChapterCode</Value>
</Value>
<Value name="4">
<Value>RangeStart</Value>
</Value>
<Value name="5">
<Value>RangeEnd</Value>
</Value>
</Data>
<State>FamilyItemState</State>
<Type>%Storage.Serial</Type>
}

}
