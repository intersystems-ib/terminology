Class Terminology.CIE.HierarchyEdge Extends (%Persistent, %Populate, %JSON.Adaptor)
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Version As %Integer [ Required ];

Property CodeType As %String(MAXLEN = 32) [ Required ];

Property HierarchyType As %String(MAXLEN = 32) [ Required ];

// CODE

Property ParentCode As %String(MAXLEN = 32) [ Required ];

Property ChildCode As %String(MAXLEN = 32) [ Required ];

Property Depth As %Integer [ Required ];

Index PK On (ReleaseId, Version, CodeType, HierarchyType, ParentCode, ChildCode) [ Unique ];

Index IXParent On (ReleaseId, Version, CodeType, HierarchyType, ParentCode, Depth);

Index IXChild On (ReleaseId, Version, CodeType, HierarchyType, ChildCode, Depth);

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
<Value>Version</Value>
</Value>
<Value name="4">
<Value>CodeType</Value>
</Value>
<Value name="5">
<Value>HierarchyType</Value>
</Value>
<Value name="6">
<Value>ParentCode</Value>
</Value>
<Value name="7">
<Value>ChildCode</Value>
</Value>
<Value name="8">
<Value>Depth</Value>
</Value>
</Data>
<DataLocation>^Terminology.CIE.HierarchyEdgeD</DataLocation>
<DefaultData>HierarchyEdgeDefaultData</DefaultData>
<IdLocation>^Terminology.CIE.HierarchyEdgeD</IdLocation>
<IndexLocation>^Terminology.CIE.HierarchyEdgeI</IndexLocation>
<StreamLocation>^Terminology.CIE.HierarchyEdgeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
