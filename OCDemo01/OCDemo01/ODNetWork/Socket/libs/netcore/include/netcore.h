/********************************************************************	

	file   :	netcore.h
	
	created:	2018/09/03 18:08
	author :	qiyun
				Copyright (c) 2018 __jin10.com__. All rights reserved.
				
	purpose:	网络库导出
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
* @purpose 		: socket 管理器
*****************************************************************************/

class NETCORE_API NetCoreMgr
{
public:
	/*@function : CreateClinetSocket
	* @author   : qiyun
	* @purpose  : 创建一个socket
	* @inparam  : ip, port,socket tag(用于回调连接状态),encryption数据是否加密,selfVerify是否内部验证
	* @outparam : 返回此socket */
	static ClientBase* CreateClinetSocket(const string &strIP, int port, uint16_t tag, T_PacketMgr *msgMgr, bool encryption = false, bool selfVerify = false);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : 创建一个支持 ssl 的 socket
	* @inparam  : ip,port,socket tag(用于回调连接状态)
	* @outparam : 返回此socket */	
	static ClientBase* CreateSSLClinetSocket(const string &strIP, int port, uint16_t tag, T_PacketMgr *msgMgr);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : 创建一个服务器端
	* @inparam  : ip, port, maxobj接受的最大连接数, encryption消息是否加密,selfVerify是否内部验证
	* @outparam : 返回此server */
	static ServerBase* CreateServer(const std::string& ip, uint16_t port, T_PacketMgr *msgMgr, uint32_t maxobj = 4096, bool encryption = false, bool selfVerify = false);

	/*@function : CreateSSLClinetSocket
	* @author   : qiyun
	* @purpose  : 创建一个支持 ssl 的 socket
	* @inparam  : ip, port, maxobj(接受的最大连接数)
	* @outparam : 返回此server */
	static ServerBase* CreateSSLServer(const std::string& ip, uint16_t port, T_PacketMgr *msgMgr, uint32_t maxobj = 4096);

	/*@function : CreatePacketMgr
	* @author   : qiyun
	* @purpose  : 创建一个支持消息管理器
	* @outparam :  */
	static T_PacketMgr& CreatePacketMgr();
	static T_PacketMgr& PacketMgrInstance();


	/*@function : SetCertFilePath
	* @author   : qiyun
	* @purpose  : 设置证书路径(如"./certs",此路径下需要有以下证书:
	client.crt,client.key,client.pem,server.crt,server.kty,server.pem,
	留空则使用内置证书,*/
	static void SetCertFilePath(const char *path);

	/*@function : FreeClientSocket
	* @author   : qiyun
	* @purpose  : 释放一个client socket
	* @outparam :  */
	static void FreeClientSocket(ClientBase * sock);


protected:

private:


};



#endif//end  __netcore_h__
