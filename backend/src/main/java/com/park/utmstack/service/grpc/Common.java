// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: common.proto

package com.park.utmstack.service.grpc;

public final class Common {
  private Common() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistryLite registry) {
  }

  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registerAllExtensions(
        (com.google.protobuf.ExtensionRegistryLite) registry);
  }
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_ListRequest_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_ListRequest_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_AuthResponse_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_AuthResponse_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_DeleteRequest_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_DeleteRequest_fieldAccessorTable;

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static  com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\014common.proto\022\005agent\"\\\n\013ListRequest\022\023\n\013" +
      "page_number\030\001 \001(\005\022\021\n\tpage_size\030\002 \001(\005\022\024\n\014" +
      "search_query\030\003 \001(\t\022\017\n\007sort_by\030\004 \001(\t\"\'\n\014A" +
      "uthResponse\022\n\n\002id\030\001 \001(\r\022\013\n\003key\030\002 \001(\t\"#\n\r" +
      "DeleteRequest\022\022\n\ndeleted_by\030\001 \001(\t*.\n\006Sta" +
      "tus\022\n\n\006ONLINE\020\000\022\013\n\007OFFLINE\020\001\022\013\n\007UNKNOWN\020" +
      "\002*)\n\rConnectorType\022\t\n\005AGENT\020\000\022\r\n\tCOLLECT" +
      "OR\020\001B-\n\036com.park.utmstack.service.grpcB\006" +
      "CommonP\001\210\001\001b\006proto3"
    };
    descriptor = com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
        });
    internal_static_agent_ListRequest_descriptor =
      getDescriptor().getMessageTypes().get(0);
    internal_static_agent_ListRequest_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_ListRequest_descriptor,
        new java.lang.String[] { "PageNumber", "PageSize", "SearchQuery", "SortBy", });
    internal_static_agent_AuthResponse_descriptor =
      getDescriptor().getMessageTypes().get(1);
    internal_static_agent_AuthResponse_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_AuthResponse_descriptor,
        new java.lang.String[] { "Id", "Key", });
    internal_static_agent_DeleteRequest_descriptor =
      getDescriptor().getMessageTypes().get(2);
    internal_static_agent_DeleteRequest_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_DeleteRequest_descriptor,
        new java.lang.String[] { "DeletedBy", });
  }

  // @@protoc_insertion_point(outer_class_scope)
}
