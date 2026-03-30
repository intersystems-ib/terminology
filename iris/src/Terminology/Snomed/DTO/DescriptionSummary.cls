Class Terminology.Snomed.DTO.DescriptionSummary Extends Terminology.Snomed.DTO.Base
{

Property DescriptionId As %String(%JSONFIELDNAME = "descriptionId");

Property ConceptId As %String(%JSONFIELDNAME = "conceptId");

Property Active As %Integer(%JSONFIELDNAME = "active");

Property TypeId As %String(%JSONFIELDNAME = "typeId");

Property Lang As %String(%JSONFIELDNAME = "lang");

Property Term As %String(%JSONFIELDNAME = "term");

Property CaseSignificanceId As %String(%JSONFIELDNAME = "caseSignificanceId");

Property EffectiveTime As %String(%JSONFIELDNAME = "effectiveTime");

Storage Default
{
<Data name="DescriptionSummaryState">
<Subscript>"DescriptionSummary"</Subscript>
<Value name="1">
<Value>DescriptionId</Value>
</Value>
<Value name="2">
<Value>ConceptId</Value>
</Value>
<Value name="3">
<Value>Active</Value>
</Value>
<Value name="4">
<Value>TypeId</Value>
</Value>
<Value name="5">
<Value>Lang</Value>
</Value>
<Value name="6">
<Value>Term</Value>
</Value>
<Value name="7">
<Value>CaseSignificanceId</Value>
</Value>
<Value name="8">
<Value>EffectiveTime</Value>
</Value>
</Data>
<State>DescriptionSummaryState</State>
<Type>%Storage.Serial</Type>
}

}
