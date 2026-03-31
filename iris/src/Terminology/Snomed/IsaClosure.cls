/// Stores the precomputed transitive closure of SNOMED IS-A relationships for fast hierarchy queries.
Class Terminology.Snomed.IsaClosure Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Closure flavor, typically stated or inferred.
Property View As %String(MAXLEN = 10) [ Required ];

/// Ancestor concept id in the hierarchy.
Property AncestorId As %BigInt [ Required ];

/// Descendant concept id in the hierarchy.
Property DescendantId As %BigInt [ Required ];

/// Number of IS-A hops between ancestor and descendant.
Property Depth As %Integer [ Required ];

Index PK On (ReleaseId, View, AncestorId, DescendantId) [ Unique ];

Index IXDesc On (ReleaseId, View, DescendantId, AncestorId);

Index IXAncDepth On (ReleaseId, View, AncestorId, Depth);

Storage Default
{
<Data name="IsaClosureDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>View</Value>
</Value>
<Value name="4">
<Value>AncestorId</Value>
</Value>
<Value name="5">
<Value>DescendantId</Value>
</Value>
<Value name="6">
<Value>Depth</Value>
</Value>
</Data>
<DataLocation>^Terminology.Snomed.IsaClosureD</DataLocation>
<DefaultData>IsaClosureDefaultData</DefaultData>
<IdLocation>^Terminology.Snomed.IsaClosureD</IdLocation>
<IndexLocation>^Terminology.Snomed.IsaClosureI</IndexLocation>
<StreamLocation>^Terminology.Snomed.IsaClosureS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
