/// Stores the resolved preferred term for a concept in a specific language and dialect.
Class Terminology.Snomed.PreferredTerm Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Concept whose preferred term was selected.
Property ConceptId As %BigInt [ Required ];

/// Base language code used for the selection.
Property Lang As %String(MAXLEN = 10) [ Required ];

/// Dialect used to resolve the preferred term.
Property Dialect As %String(MAXLEN = 20) [ Required ];

/// Description chosen as the preferred term.
Property DescriptionId As %BigInt [ Required ];

/// Display text of the selected preferred term.
Property Term As %String(MAXLEN = 2000) [ Required ];

/// Normalized version of the term used for searching.
Property TermNorm As %String(MAXLEN = 2000);

Index PK On (ReleaseId, ConceptId, Lang, Dialect) [ Unique ];

Index IXTermNorm On (ReleaseId, Lang, Dialect, TermNorm);

Index IXDescId On (ReleaseId, DescriptionId);

Index IXTermNormFind On (TermNorm) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Storage Default
{
<Data name="PreferredTermDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>ConceptId</Value>
</Value>
<Value name="4">
<Value>Lang</Value>
</Value>
<Value name="5">
<Value>Dialect</Value>
</Value>
<Value name="6">
<Value>DescriptionId</Value>
</Value>
<Value name="7">
<Value>Term</Value>
</Value>
<Value name="8">
<Value>TermNorm</Value>
</Value>
</Data>
<DataLocation>^Terminology6D3E.PreferredTermD</DataLocation>
<DefaultData>PreferredTermDefaultData</DefaultData>
<IdLocation>^Terminology6D3E.PreferredTermD</IdLocation>
<IndexLocation>^Terminology6D3E.PreferredTermI</IndexLocation>
<StreamLocation>^Terminology6D3E.PreferredTermS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
