/********************************************************************	

	file   :	netcore.h
	
	created:	2018/09/03 18:08
	author :	qiyun
				Copyright (c) 2018 __jin10.com__. All rights reserved.
				
	purpose:	����⵼��
*********************************************************************/

#pragma  once
#ifndef __netcore_h__
#define __netcore_h__

#include <string>
#include "SocketBase.h"

using namespace std;


/*****************************************************************************
* @class name 	: NetCoreMgr
* @author 		: qiyun
* @purpose 		: socket ������
*****************************************************************************/

class NETCORE_API NetCoreMgr
{
public:
	/*@function : CreateClinetSocket
	* @author   : qiyun
	* @purpose  : ����һ��socket
	* @inparam  : ip, port,socket tag(���ڻص�����״̬),encryption�����Ƿ����,selfVerify�Ƿ��ڲ���֤
	* @outparam : ���ش�socket */
	static ClientBase* CreateClinetSocket(const string &strIP, int port, uint16_t tag, T_PacketMgr *msgMgr, bool encryption = false, bool selfVerify = false);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : ����һ��֧�� ssl �� socket
	* @inparam  : ip,port,socket tag(���ڻص�����״̬)
	* @outparam : ���ش�socket */	
	static ClientBase* CreateSSLClinetSocket(const string &strIP, int port, uint16_t tag, T_PacketMgr *msgMgr);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : ����һ����������
	* @inparam  : ip, port, maxobj���ܵ����������, encryption��Ϣ�Ƿ����,selfVerify�Ƿ��ڲ���֤
	* @outparam : ���ش�server */
	static ServerBase* CreateServer(const std::string& ip, uint16_t port, T_PacketMgr *msgMgr, uint32_t maxobj = 4096, bool encryption = false, bool selfVerify = false);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : ����һ��֧�� ssl �� socket
	* @inparam  : ip, port, maxobj(���ܵ����������)
	* @outparam : ���ش�server */
	static ServerBase* CreateSSLServer(const std::string& ip, uint16_t port, T_PacketMgr *msgMgr, uint32_t maxobj = 4096);

	/*@function : CreatePacketMgr
	* @author   : qiyun
	* @purpose  : ����һ��֧����Ϣ������
	* @outparam :  */
	static T_PacketMgr& CreatePacketMgr();
	static T_PacketMgr& PacketMgrInstance();


	/*@function : SetCertFilePath
	* @author   : qiyun
	* @purpose  : ����֤��·��(��"./certs",��·������Ҫ������֤��:
	client.crt,client.key,client.pem,server.crt,server.kty,server.pem,
	������ʹ������֤��,*/
	static void SetCertFilePath(const char *path);

	/*@function : FreeClientSocket
	* @author   : qiyun
	* @purpose  : �ͷ�һ��client socket
	* @outparam :  */
	static void FreeClientSocket(ClientBase * sock);


protected:

private:


};



#endif//end  __netcore_h__
