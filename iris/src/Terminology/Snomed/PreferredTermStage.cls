/// Staging table used while rebuilding preferred terms before promoting them to the final table.
Class Terminology.Snomed.PreferredTermStage Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 100) [ Required ];

/// Base language code used for the candidate term.
Property Lang As %String(MAXLEN = 10) [ Required ];

/// Dialect used for the candidate term.
Property Dialect As %String(MAXLEN = 20) [ Required ];

/// Concept whose preferred term is being staged.
Property ConceptId As %BigInt [ Required ];

/// Candidate description selected for the concept.
Property DescriptionId As %BigInt [ Required ];

/// Candidate display text.
Property Term As %String(MAXLEN = 2000) [ Required ];

/// Normalized version of the candidate term used for searching.
Property TermNorm As %String(MAXLEN = 2000);

Index PK On (ReleaseId, Lang, Dialect, ConceptId) [ IdKey, Unique ];

Index IXDescription On (ReleaseId, DescriptionId);

Index IXScope On (ReleaseId, Lang, Dialect);

Storage Default
{
<Data name="PreferredTermStageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DescriptionId</Value>
</Value>
<Value name="3">
<Value>Term</Value>
</Value>
<Value name="4">
<Value>TermNorm</Value>
</Value>
</Data>
<DataLocation>^Terminolog6D3E.PreferredTeA526D</DataLocation>
<DefaultData>PreferredTermStageDefaultData</DefaultData>
<IdLocation>^Terminolog6D3E.PreferredTeA526D</IdLocation>
<IndexLocation>^Terminolog6D3E.PreferredTeA526I</IndexLocation>
<StreamLocation>^Terminolog6D3E.PreferredTeA526S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
