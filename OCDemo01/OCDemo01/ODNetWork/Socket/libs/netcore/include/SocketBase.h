/********************************************************************	

	file   :	socketBase.h
	
	created:	2018/09/05 10:39
	author :	qiyun
				Copyright (c) 2018 __jin10.com__. All rights reserved.
				
	purpose:	socket ������
*********************************************************************/
#ifndef __socketBase_h__
#define __socketBase_h__

#include "MsgPacket.h"
#include <stdarg.h>
#if defined(_WIN32) || defined(__WIN32__) || defined(__WINDOWS__)

#ifdef	NETCORE_EXPORTS       
#define NETCORE_API  __declspec(dllexport)
#else
#define NETCORE_API  __declspec(dllimport)
#endif

#else
#define NETCORE_API
#endif
namespace MD5
{
	std::string BuildMd5(const std::string &str);
};


enum SocketEvent
{
	eSocketEvent_on_connect = 1,//���ӳɹ�
	eSocketEvent_on_got_key,//�õ�����key
	eSocketEvent_on_vierify,//�ڲ���֤ͨ��

	eSocketEvent_on_close,//�ر�

};


enum SelfVerify		//�Ƿ�ʹ���ڲ���֤
{
	eSelfVerify_null = 0,//��ʹ��
	eSelfVerify_success,//��֤ʾͨ��
	eSelfVerify_failed,//��֤ʧ��

	eSelfVerify_successKey = 7823,//��֤ͨ����ʶ��
};

template<class T_Packet>
class NETCORE_API PacketMgrBase
{
public:
	virtual void clear() = 0;
	virtual T_Packet&	Allocate() = 0;
	virtual T_Packet *PopReceivePacket() = 0;
	virtual T_Packet *PopSendMsg() = 0;

	virtual void Free(T_Packet &msg) = 0;
	virtual void PushReceivePacket(T_Packet &msg) = 0;
	virtual void PushSendMsg(T_Packet &msg) = 0;

	virtual size_t RecvMsgSize() = 0;
	virtual size_t FreeMsgSize() = 0;
	virtual size_t sendMsgSize() = 0;
};

typedef PacketMgrBase<MsgPacket> T_PacketMgr;

//
class NETCORE_API ClientBase
{
public:
	virtual void sendPacket(MsgPacket &msg) = 0;//������Ϣ
	virtual void safeSendPacket(MsgPacket &msg) = 0;//�԰�װ�Ļ��Ʒ�����Ϣ,�������Ϊ�ض�����
	virtual void connect(const std::string& ip, unsigned short port) = 0;//����������һ����ַ

	virtual void stop() = 0;
	virtual void start() = 0;

	virtual void setTag(uint16_t tag) = 0;
	virtual uint16_t getTag() = 0;
	virtual void SetPacketMgr(T_PacketMgr* mgr) = 0;
	virtual void disconnect() = 0;

protected:
private:
};


class NETCORE_API ServerBase
{
public:

	virtual int  CheckUnloginSocketTimeOut(uint32_t timeOut) { return 0; }//������ӳɹ���δ��֤��socket ��ʱ
	virtual void force_shutdown_client(uint_fast64_t clientID) {} //�ر�ָ��client
	virtual bool sendPacketToClient(uint_fast64_t clientID, MsgPacket &msg) = 0;//��ָ��ID���û�������Ϣ
	virtual void broadcastPacket(MsgPacket &msg) = 0;//�㲥��Ϣ

protected:
private:

};




//for socket log unified_out////////////////////////////////////////////////////////////////////////	

#define OUT_BUF_NUM  4096
#define Do_log(_level_)  if (s_logerBase != nullptr && _level_ >= s_loglevel) { char output_buff[OUT_BUF_NUM];  log_out_helper(output_buff);  s_logerBase->LogString(_level_, output_buff); }
#define log_out_helper(_buff_)  va_list ap; va_start(ap, fmt); make_all_out(_buff_, OUT_BUF_NUM, fmt, ap); va_end(ap); 


enum SOCKET_LOG_LEVEL//match ENUM_LOG_LEVEL
{
	eLOG_LEVEL_TRACE = 0,
	eLOG_LEVEL_DEBUG,
	eLOG_LEVEL_INFO,
	eLOG_LEVEL_WARN,
	eLOG_LEVEL_ERROR,
	eLOG_LEVEL_ALARM,
	eLOG_LEVEL_FATAL,
};

class unified_out;
static unified_out *s_logerBase;
static SOCKET_LOG_LEVEL s_loglevel = eLOG_LEVEL_TRACE;
class NETCORE_API unified_out
{
protected:

	static void make_all_out(char* buff, size_t buff_len, const char* fmt, va_list& ap)
	{
#if defined(_MSC_VER) && _MSC_VER >= 1400
		vsnprintf_s(buff, buff_len, _TRUNCATE, fmt, ap);
#else
		vsnprintf(buff, buff_len, fmt, ap);
#endif
	}


public:
	unified_out() { s_logerBase = this; }
	~unified_out() { if (s_logerBase == this) s_logerBase = nullptr; }
	virtual void LogString(int iLevel, const char * buff) {};
public:
	static void SetSocketLogLevel(SOCKET_LOG_LEVEL level) { s_loglevel = level; }

	static void debug_out(const char* fmt, ...)		{ Do_log(eLOG_LEVEL_DEBUG); }
	static void info_out(const char* fmt, ...)		{ Do_log(eLOG_LEVEL_INFO); }
	static void warning_out(const char* fmt, ...)	{ Do_log(eLOG_LEVEL_WARN); }
	static void error_out(const char* fmt, ...)		{ Do_log(eLOG_LEVEL_ERROR); }
	static void alarm_out(const char* fmt, ...)		{ Do_log(eLOG_LEVEL_ALARM); }
	static void fatal_out(const char* fmt, ...)		{ Do_log(eLOG_LEVEL_FATAL); }

};


#endif
