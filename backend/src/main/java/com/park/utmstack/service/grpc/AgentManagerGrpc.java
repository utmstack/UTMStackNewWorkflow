// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: agent.proto

package com.park.utmstack.service.grpc;

public final class AgentManagerGrpc {
  private AgentManagerGrpc() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistryLite registry) {
  }

  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registerAllExtensions(
        (com.google.protobuf.ExtensionRegistryLite) registry);
  }
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_AgentRequest_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_AgentRequest_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_ListAgentsResponse_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_ListAgentsResponse_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_Agent_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_Agent_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_BidirectionalStream_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_BidirectionalStream_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_UtmCommand_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_UtmCommand_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_CommandResult_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_CommandResult_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_ListAgentsCommandsResponse_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_ListAgentsCommandsResponse_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_agent_AgentCommand_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_agent_AgentCommand_fieldAccessorTable;

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static  com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\013agent.proto\022\005agent\032\037google/protobuf/ti" +
      "mestamp.proto\032\014common.proto\"\325\001\n\014AgentReq" +
      "uest\022\n\n\002ip\030\001 \001(\t\022\020\n\010hostname\030\002 \001(\t\022\n\n\002os" +
      "\030\003 \001(\t\022\020\n\010platform\030\004 \001(\t\022\017\n\007version\030\005 \001(" +
      "\t\022\023\n\013register_by\030\006 \001(\t\022\013\n\003mac\030\007 \001(\t\022\030\n\020o" +
      "s_major_version\030\010 \001(\t\022\030\n\020os_minor_versio" +
      "n\030\t \001(\t\022\017\n\007aliases\030\n \001(\t\022\021\n\taddresses\030\013 " +
      "\001(\t\"?\n\022ListAgentsResponse\022\032\n\004rows\030\001 \003(\0132" +
      "\014.agent.Agent\022\r\n\005total\030\002 \001(\005\"\212\002\n\005Agent\022\n" +
      "\n\002ip\030\001 \001(\t\022\020\n\010hostname\030\002 \001(\t\022\n\n\002os\030\003 \001(\t" +
      "\022\035\n\006status\030\004 \001(\0162\r.agent.Status\022\020\n\010platf" +
      "orm\030\005 \001(\t\022\017\n\007version\030\006 \001(\t\022\021\n\tagent_key\030" +
      "\007 \001(\t\022\n\n\002id\030\010 \001(\r\022\021\n\tlast_seen\030\t \001(\t\022\013\n\003" +
      "mac\030\n \001(\t\022\030\n\020os_major_version\030\013 \001(\t\022\030\n\020o" +
      "s_minor_version\030\014 \001(\t\022\017\n\007aliases\030\r \001(\t\022\021" +
      "\n\taddresses\030\016 \001(\t\"u\n\023BidirectionalStream" +
      "\022$\n\007command\030\001 \001(\0132\021.agent.UtmCommandH\000\022&" +
      "\n\006result\030\002 \001(\0132\024.agent.CommandResultH\000B\020" +
      "\n\016stream_message\"\214\001\n\nUtmCommand\022\020\n\010agent" +
      "_id\030\001 \001(\t\022\017\n\007command\030\002 \001(\t\022\023\n\013executed_b" +
      "y\030\003 \001(\t\022\016\n\006cmd_id\030\004 \001(\t\022\023\n\013origin_type\030\005" +
      " \001(\t\022\021\n\torigin_id\030\006 \001(\t\022\016\n\006reason\030\007 \001(\t\"" +
      "r\n\rCommandResult\022\020\n\010agent_id\030\001 \001(\t\022\016\n\006re" +
      "sult\030\002 \001(\t\022/\n\013executed_at\030\003 \001(\0132\032.google" +
      ".protobuf.Timestamp\022\016\n\006cmd_id\030\004 \001(\t\"N\n\032L" +
      "istAgentsCommandsResponse\022!\n\004rows\030\001 \003(\0132" +
      "\023.agent.AgentCommand\022\r\n\005total\030\002 \001(\005\"\261\002\n\014" +
      "AgentCommand\022.\n\ncreated_at\030\001 \001(\0132\032.googl" +
      "e.protobuf.Timestamp\022.\n\nupdated_at\030\002 \001(\013" +
      "2\032.google.protobuf.Timestamp\022\020\n\010agent_id" +
      "\030\003 \001(\r\022\017\n\007command\030\004 \001(\t\0221\n\016command_statu" +
      "s\030\005 \001(\0162\031.agent.AgentCommandStatus\022\016\n\006re" +
      "sult\030\006 \001(\t\022\023\n\013executed_by\030\007 \001(\t\022\016\n\006cmd_i" +
      "d\030\010 \001(\t\022\016\n\006reason\030\t \001(\t\022\023\n\013origin_type\030\n" +
      " \001(\t\022\021\n\torigin_id\030\013 \001(\t*W\n\022AgentCommandS" +
      "tatus\022\020\n\014NOT_EXECUTED\020\000\022\t\n\005QUEUE\020\001\022\013\n\007PE" +
      "NDING\020\002\022\014\n\010EXECUTED\020\003\022\t\n\005ERROR\020\0042\341\002\n\014Age" +
      "ntService\022;\n\rRegisterAgent\022\023.agent.Agent" +
      "Request\032\023.agent.AuthResponse\"\000\022:\n\013Delete" +
      "Agent\022\024.agent.DeleteRequest\032\023.agent.Auth" +
      "Response\"\000\022=\n\nListAgents\022\022.agent.ListReq" +
      "uest\032\031.agent.ListAgentsResponse\"\000\022K\n\013Age" +
      "ntStream\022\032.agent.BidirectionalStream\032\032.a" +
      "gent.BidirectionalStream\"\000(\0010\001\022L\n\021ListAg" +
      "entCommands\022\022.agent.ListRequest\032!.agent." +
      "ListAgentsCommandsResponse\"\0002O\n\014PanelSer" +
      "vice\022?\n\016ProcessCommand\022\021.agent.UtmComman" +
      "d\032\024.agent.CommandResult\"\000(\0010\001B7\n\036com.par" +
      "k.utmstack.service.grpcB\020AgentManagerGrp" +
      "cP\001\210\001\001b\006proto3"
    };
    descriptor = com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
          com.google.protobuf.TimestampProto.getDescriptor(),
          com.park.utmstack.service.grpc.Common.getDescriptor(),
        });
    internal_static_agent_AgentRequest_descriptor =
      getDescriptor().getMessageTypes().get(0);
    internal_static_agent_AgentRequest_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_AgentRequest_descriptor,
        new java.lang.String[] { "Ip", "Hostname", "Os", "Platform", "Version", "RegisterBy", "Mac", "OsMajorVersion", "OsMinorVersion", "Aliases", "Addresses", });
    internal_static_agent_ListAgentsResponse_descriptor =
      getDescriptor().getMessageTypes().get(1);
    internal_static_agent_ListAgentsResponse_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_ListAgentsResponse_descriptor,
        new java.lang.String[] { "Rows", "Total", });
    internal_static_agent_Agent_descriptor =
      getDescriptor().getMessageTypes().get(2);
    internal_static_agent_Agent_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_Agent_descriptor,
        new java.lang.String[] { "Ip", "Hostname", "Os", "Status", "Platform", "Version", "AgentKey", "Id", "LastSeen", "Mac", "OsMajorVersion", "OsMinorVersion", "Aliases", "Addresses", });
    internal_static_agent_BidirectionalStream_descriptor =
      getDescriptor().getMessageTypes().get(3);
    internal_static_agent_BidirectionalStream_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_BidirectionalStream_descriptor,
        new java.lang.String[] { "Command", "Result", "StreamMessage", });
    internal_static_agent_UtmCommand_descriptor =
      getDescriptor().getMessageTypes().get(4);
    internal_static_agent_UtmCommand_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_UtmCommand_descriptor,
        new java.lang.String[] { "AgentId", "Command", "ExecutedBy", "CmdId", "OriginType", "OriginId", "Reason", });
    internal_static_agent_CommandResult_descriptor =
      getDescriptor().getMessageTypes().get(5);
    internal_static_agent_CommandResult_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_CommandResult_descriptor,
        new java.lang.String[] { "AgentId", "Result", "ExecutedAt", "CmdId", });
    internal_static_agent_ListAgentsCommandsResponse_descriptor =
      getDescriptor().getMessageTypes().get(6);
    internal_static_agent_ListAgentsCommandsResponse_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_ListAgentsCommandsResponse_descriptor,
        new java.lang.String[] { "Rows", "Total", });
    internal_static_agent_AgentCommand_descriptor =
      getDescriptor().getMessageTypes().get(7);
    internal_static_agent_AgentCommand_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_agent_AgentCommand_descriptor,
        new java.lang.String[] { "CreatedAt", "UpdatedAt", "AgentId", "Command", "CommandStatus", "Result", "ExecutedBy", "CmdId", "Reason", "OriginType", "OriginId", });
    com.google.protobuf.TimestampProto.getDescriptor();
    com.park.utmstack.service.grpc.Common.getDescriptor();
  }

  // @@protoc_insertion_point(outer_class_scope)
}
