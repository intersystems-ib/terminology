Class Terminology.Loinc.HierarchyEdge Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property ParentCode As %String(MAXLEN = 20) [ Required ];

Property ChildCode As %String(MAXLEN = 20) [ Required ];

Property Axis As %String(MAXLEN = 50);

Index PK On (ReleaseId, ParentCode, ChildCode) [ Unique ];

Index IXChild On (ReleaseId, ChildCode, ParentCode);

Storage Default
{
<Data name="HierarchyEdgeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>ParentCode</Value>
</Value>
<Value name="4">
<Value>ChildCode</Value>
</Value>
<Value name="5">
<Value>Axis</Value>
</Value>
</Data>
<DataLocation>^TerminologyB303.HierarchyEdgeD</DataLocation>
<DefaultData>HierarchyEdgeDefaultData</DefaultData>
<IdLocation>^TerminologyB303.HierarchyEdgeD</IdLocation>
<IndexLocation>^TerminologyB303.HierarchyEdgeI</IndexLocation>
<StreamLocation>^TerminologyB303.HierarchyEdgeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
