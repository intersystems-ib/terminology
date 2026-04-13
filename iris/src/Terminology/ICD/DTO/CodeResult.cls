Class Terminology.ICD.DTO.CodeResult Extends Terminology.ICD.DTO.Base
{

Property Code As %String;

Property Description As %String;

Property Version As %Integer;

Property CodeType As %String;

Property ParentCode As %String;

Property ChapterCode As %String;

Property FamilyCode As %String;

Property HierarchyLevel As %Integer;

Property NodeFinal As %Boolean;

Property Active As %Boolean;

Property Manifestation As %Boolean;

Property Perinatal As %Boolean;

Property Pediatric As %Boolean;

Property Obstetric As %Boolean;

Property Adult As %Boolean;

Property Female As %Boolean;

Property Male As %Boolean;

Property PoaExempt As %Boolean;

Property DpNotPrincipal As %Boolean;

Property Vcdp As %Boolean;

Storage Default
{
<Data name="CodeResultState">
<Subscript>"CodeResult"</Subscript>
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
<Value>ParentCode</Value>
</Value>
<Value name="6">
<Value>ChapterCode</Value>
</Value>
<Value name="7">
<Value>FamilyCode</Value>
</Value>
<Value name="8">
<Value>HierarchyLevel</Value>
</Value>
<Value name="9">
<Value>NodeFinal</Value>
</Value>
<Value name="10">
<Value>Active</Value>
</Value>
<Value name="11">
<Value>Manifestation</Value>
</Value>
<Value name="12">
<Value>Perinatal</Value>
</Value>
<Value name="13">
<Value>Pediatric</Value>
</Value>
<Value name="14">
<Value>Obstetric</Value>
</Value>
<Value name="15">
<Value>Adult</Value>
</Value>
<Value name="16">
<Value>Female</Value>
</Value>
<Value name="17">
<Value>Male</Value>
</Value>
<Value name="18">
<Value>PoaExempt</Value>
</Value>
<Value name="19">
<Value>DpNotPrincipal</Value>
</Value>
<Value name="20">
<Value>Vcdp</Value>
</Value>
</Data>
<State>CodeResultState</State>
<Type>%Storage.Serial</Type>
}

}
