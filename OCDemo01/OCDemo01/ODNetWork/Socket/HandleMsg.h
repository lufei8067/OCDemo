//
//  HandleMsg.h
//  appsocket
//
//  Created by qiyun on 2018/10/31.
//  Copyright © 2018年 qiyun. All rights reserved.
//

//#include "socket_common.h"
#include <map>
#include "Kline.h"
#include "netcore.h"

class CHandleMsg
{
public:
    
    static CHandleMsg & getInstance(){static CHandleMsg s_inst; return s_inst;}
    
    bool init();
    bool parseMsg();
    
    bool createSocket();
    void disconnect();
    

    void requestKlineQuote(vector<KlineQuote> vtCode, uint32_t iInverval);//iInverval报价频率（毫秒）
    void requestAdvancedQuote(vector<string> vtCode, uint32_t iInverval);//iInverval报价频率（毫秒）
    void requestHistoryFile(const string &strCode, uint8_t itimeType, uint64_t iTime, uint16_t iWinID, int8_t iWay);

    void requestSort(vector<uint16_t> &vtSortID);//请求排行榜
//    void requestWarn(vector<STWarn> &vtWarn);//请求高级预警
    
    //解析历史数据，文件经gzip压缩，需先解压后传数据和长度，结果在vtResult中，返回得到的K线数
    static S_KLine* parseHistoryKLine(unsigned char *_pData, unsigned int _iFileSize, uint32_t &iSize);

    bool sendMsg(MsgPacket& msg);
    
    int AddWarn(STWarn &warn);//添加一个预警，返回新预警ID,必须请求到旧预警列表(则连接成功)后调用
    void SetWarn(STWarn &warn);//添加/修改预警
    void deleteWarn(vector<uint32_t>& vtID,uint32_t iUID);//删除预警
    void clearWarn(uint32_t iUID);//清空所有预警
    void sendUserId(uint32_t uid);//发送用户id
    void HandleSendSession(MsgPacket &msg);//发送回话结果
    
protected:
    ////////////////////////
    void HandleNewsFlash(MsgPacket &msg);
    void HandleUserTestsMsg(MsgPacket &msg);
    void HandleNewsSocketEvent(MsgPacket &msg);

    
    void HandleLoginResult(MsgPacket &msg);

    void HandleMultipleLoginKickOff(MsgPacket &msg);
    void HandleVipExpired(MsgPacket &msg);

    void HandleFirstKline(MsgPacket &msg);

    void HandleKlineQuote(MsgPacket &msg);
    void HandleAdvancedQuote(MsgPacket &msg);
    void HandleRequestKlineCallbck(MsgPacket &msg);
    void HandleRequestAdvancedCallback(MsgPacket &msg);
    
    void HandleRequestHistoryFileCallback(MsgPacket &msg);
    void HandleChangePhaseCode(MsgPacket &msg);
    void HandleSortTypeList(MsgPacket &msg);//下发排行榜列表
    void HandleSort(MsgPacket &msg);//下发排行榜数据
    void HandleRequestSortCallback(MsgPacket &msg);//请求排行榜数据返回
    void HandleWarn(MsgPacket &msg);//高级预警响应
    
    void HandleEventFlash(MsgPacket &msg);//事件
    void HandleCacheNewsFlash(MsgPacket &msg);//连接成功后下发缓存的快讯
    void HandleWarnOperation(MsgPacket &msg);//预警相关
    void warnOperation(STWarn &warn, uint16_t code);
    
protected:
    ClientBase *m_newsSocket;
    ClientBase *m_quoteSocket;
    
    uint16_t m_flashSocketState;
    uint16_t m_quoteSocketState;
    bool m_bIsIPv6;
    T_PacketMgr &m_packetMgr;
    bool    m_bGotWarnList;
    vector<STWarn> m_vtWarn;

private:
    CHandleMsg();
    ~CHandleMsg();
    

    
    typedef void (CHandleMsg::*msg_handler)(MsgPacket&);
    void AddMsgHandler(uint16_t id, msg_handler handler);
    void HandleMessage(MsgPacket& msg);
    void connectNewsSocket(string ip, int port);
    void connectQuoteSocket(string ip, int port);
    void sendLogin();
    std::map<uint16_t, msg_handler> m_mapHandlers;
    
};
