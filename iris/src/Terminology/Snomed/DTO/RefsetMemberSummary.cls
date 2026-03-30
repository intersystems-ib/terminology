Class Terminology.Snomed.DTO.RefsetMemberSummary Extends Terminology.Snomed.DTO.Base
{

Property RefsetId As %String(%JSONFIELDNAME = "refsetId");

Property MemberId As %String(%JSONFIELDNAME = "memberId");

Property ConceptId As %String(%JSONFIELDNAME = "conceptId");

Property PreferredTerm As %String(%JSONFIELDNAME = "preferredTerm");

Storage Default
{
<Data name="RefsetMemberSummaryState">
<Subscript>"RefsetMemberSummary"</Subscript>
<Value name="1">
<Value>RefsetId</Value>
</Value>
<Value name="2">
<Value>MemberId</Value>
</Value>
<Value name="3">
<Value>ConceptId</Value>
</Value>
<Value name="4">
<Value>PreferredTerm</Value>
</Value>
</Data>
<State>RefsetMemberSummaryState</State>
<Type>%Storage.Serial</Type>
}

}
