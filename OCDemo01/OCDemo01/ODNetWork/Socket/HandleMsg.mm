//
//  HandleMsg.m
//  appsocket
//
//  Created by qiyun on 2018/10/31.
//  Copyright © 2018年 qiyun. All rights reserved.
//

#include "HandleMsg.h"
#include "ProtocolCode.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

using namespace ProtocolCode;

const uint16_t NewsSocketTag = 60002;

const uint16_t QuoteSocketTag = 60004;

const uint64_t Max_Hisroty_File_Time = 999990000000;//第一次请求历史数据时最大时间戳

string getIPV6(const char *mHost)
{
    if (mHost == NULL) return "";
    struct addrinfo *res0;
    struct addrinfo hints;
    struct addrinfo *res;

    memset(&hints, 0, sizeof(hints));

    hints.ai_flags = AI_DEFAULT;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    int n;
    if ((n = getaddrinfo(mHost, "https", &hints, &res0)) != 0) {
        //printf("getaddrinfo failed %d", n);
        UILOG(@"getaddrinfo failed %d", n);
        
        return "";
    }

    struct sockaddr_in6 *addr6;
    struct sockaddr_in *addr;
    const char *pszTemp = nullptr;

    for (res = res0; res; res = res->ai_next) {
        char buf[32];
        if (res->ai_family == AF_INET6) {
            addr6 = (struct sockaddr_in6 *)res->ai_addr;
            pszTemp = inet_ntop(AF_INET6, &addr6->sin6_addr, buf, sizeof(buf));
        } else {
            addr = (struct sockaddr_in *)res->ai_addr;
            pszTemp = inet_ntop(AF_INET, &addr->sin_addr, buf, sizeof(buf));
        }

        break;
    }

    freeaddrinfo(res0);

    if (pszTemp != nullptr) {
        string strIPV6IP(pszTemp);//
        if (!strIPV6IP.empty()) {
            if (strIPV6IP.find(":") != string::npos) {//ipv6
                //printf("using ipv6:%s\n", strIPV6IP.c_str());
                UILOG(@"using ipv6:%s\n", strIPV6IP.c_str());
                return strIPV6IP;
            }
        }
    }

    //printf("using ipv4\n");
    UILOG(@"using ipv4\n");
    return "";
}

CHandleMsg::CHandleMsg()
    : m_bIsIPv6(false)
    , m_bGotWarnList(false)
    , m_newsSocket(nullptr)
    , m_quoteSocket(nullptr)
    , m_packetMgr(NetCoreMgr::CreatePacketMgr())
{
    
    AddMsgHandler(NewsSocketTag, &CHandleMsg::HandleNewsSocketEvent);
    AddMsgHandler(QuoteSocketTag, &CHandleMsg::HandleNewsSocketEvent);

    AddMsgHandler(MSG_USER_LOGIN_NEWS, &CHandleMsg::HandleLoginResult);

    AddMsgHandler(MSG_SEND_USER_VIP_EXPIRED, &CHandleMsg::HandleVipExpired);
    AddMsgHandler(MSG_USER_MULTIPLE_LOGIN_KICK_OFF, &CHandleMsg::HandleMultipleLoginKickOff);

    //news
    AddMsgHandler(MSG_NEWS_FLASH, &CHandleMsg::HandleNewsFlash);
    AddMsgHandler(MSG_VIP_NEWS_FLASH, &CHandleMsg::HandleNewsFlash);
    
    
    //quote
    AddMsgHandler(MSG_KLINE_QUOTE, &CHandleMsg::HandleKlineQuote);
    AddMsgHandler(MSG_ADVANCED_QUOTE, &CHandleMsg::HandleAdvancedQuote);
    AddMsgHandler(MSG_REQUEST_STOCK_KLINE, &CHandleMsg::HandleRequestKlineCallbck);
    AddMsgHandler(MSG_REQUEST_STOCK_ADVANCED, &CHandleMsg::HandleRequestAdvancedCallback);

    AddMsgHandler(MSG_HISTORY_FILE_NAME, &CHandleMsg::HandleRequestHistoryFileCallback);
    AddMsgHandler(MSG_CHANGE_PHASE_CODE, &CHandleMsg::HandleChangePhaseCode);
    AddMsgHandler(MSG_SEND_SORT_LIST, &CHandleMsg::HandleSort);
    AddMsgHandler(MSG_REQUEST_SORT_LIST, &CHandleMsg::HandleRequestSortCallback);
    AddMsgHandler(MSG_REQUEST_SORT_TYPE_LIST, &CHandleMsg::HandleSortTypeList);
    AddMsgHandler(MSG_FIRST_KLINE_QUOTE, &CHandleMsg::HandleFirstKline);

    AddMsgHandler(MSG_WARN_OPEARTION, &CHandleMsg::HandleWarnOperation);

    //事件
    AddMsgHandler(MSG_EVENT_FLASH, &CHandleMsg::HandleEventFlash);
    AddMsgHandler(MSG_SEND_CACHE_NEWS, &CHandleMsg::HandleCacheNewsFlash);
    AddMsgHandler(MSG_SEND_SESSION_INFO_RESULT, &CHandleMsg::HandleSendSession);
}

void CHandleMsg::HandleSendSession(MsgPacket &msg)//发送回话结果
{
    uint16_t iCount;
    msg >> iCount;

    //printf("send session number:%d\n", iCount);
    UILOG(@"send session number:%d\n", iCount);
}

CHandleMsg::~CHandleMsg()
{
}

bool CHandleMsg::init()
{
    return createSocket();
}

bool CHandleMsg::createSocket()
{
    string strNewsIP = [[ODGlobalVar getNewsIp] UTF8String];
    int newsPort = (int)[ODGlobalVar getNewsPort];

    string strQuoteIP = [[ODGlobalVar getGateWayIp] UTF8String];
    int quotePort = (int)[ODGlobalVar getGateWayPort];

    NSString *ipv6Host = [ODGlobalVar getGateWayIp_ipv6];

//    if ([GTAccountManager instance].isVip) {
//        strNewsIP = [[GTGlobalVar getNewsVipIp] UTF8String];
//        newsPort = (int)[GTGlobalVar getNewsVipPort];
//        ipv6Host = [GTGlobalVar getNewsVipIp_ipv6];
//    }

    string strIPV6 = getIPV6(ipv6Host.UTF8String);
    bool bIpv6 = !strIPV6.empty();
    m_bIsIPv6 = bIpv6;
    if (bIpv6) {
        strNewsIP = strQuoteIP = strIPV6;
        quotePort = (int)[ODGlobalVar getGateWayPort_ipv6];
        newsPort = (int)[ODGlobalVar getNewsPort_ipv6];

//        if ([GTAccountManager instance].isVip) {
//            newsPort = (int)[GTGlobalVar getNewsVipPort_ipv6];
//        }
    }

    connectNewsSocket(strNewsIP, newsPort);

    connectQuoteSocket(strQuoteIP, quotePort);

    //printf("create new socket_quote, ipv6:%d strQuoteIP=%s, quotePort=%d\n", m_bIsIPv6, strQuoteIP.c_str(), quotePort);
    UILOG(@"create new socket_quote, ipv6:%d strQuoteIP=%s, quotePort=%d\n", m_bIsIPv6, strQuoteIP.c_str(), quotePort);
//    printf("create new socket_news,vip:%d, ipv6:%d strNewsIP=%s, newsPort=%d\n", [GTAccountManager instance].isVip, m_bIsIPv6, strNewsIP.c_str(), newsPort);

    return true;
}

void CHandleMsg::connectNewsSocket(string ip, int port)
{
    if (m_newsSocket == nullptr) { //NetCoreMgr::FreeClientSocket(m_newsSocket);
        m_newsSocket = NetCoreMgr::CreateClinetSocket(ip, port, NewsSocketTag, &m_packetMgr, true, true);
    } else {
        m_newsSocket->connect(ip, port);
    }
}

void CHandleMsg::connectQuoteSocket(string ip, int port)
{
    if (m_quoteSocket == nullptr) { //NetCoreMgr::FreeClientSocket(m_newsSocket);
        m_quoteSocket = NetCoreMgr::CreateClinetSocket(ip, port, QuoteSocketTag, &m_packetMgr, true, true);
    } else {
        m_quoteSocket->connect(ip, port);
    }
}

void CHandleMsg::disconnect()
{
    //DEL_ST_SOCKET(m_newsSocket);
    //DEL_ST_SOCKET(m_quoteSocket);
}

void CHandleMsg::AddMsgHandler(uint16_t id, msg_handler handler)
{
    m_mapHandlers[id] = handler;
}

void CHandleMsg::HandleMessage(MsgPacket& msg)
{
    uint16_t opcode = msg.GetOpcode();
    std::map<uint16_t, msg_handler>::iterator itr = m_mapHandlers.find(opcode);
    if (itr != m_mapHandlers.end()) {
        (this->*(itr->second))(msg);
    } else {
        //printf("HandleMessage failed:%d.......\n", opcode);
        UILOG(@"HandleMessage failed:%d.......\n", opcode);
    }
}

bool CHandleMsg::parseMsg()
{
    int iSize = 0;
    MsgPacket *msg = m_packetMgr.PopReceivePacket();
    while (msg != nullptr) {
        HandleMessage(*msg);

        m_packetMgr.Free(*msg);

        msg = m_packetMgr.PopReceivePacket();

        iSize++;
    }

    return iSize > 0;
}

//事件
void CHandleMsg::HandleEventFlash(MsgPacket &msg)
{
    string strMsg;
    msg >> strMsg;

    //printf("event:%s\n", strMsg.c_str());
    UILOG(@"event:%s\n", strMsg.c_str());

    NSString *jsonString = [NSString stringWithUTF8String:strMsg.c_str()];

    if (jsonString != nil) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if (!err) {
            UILOG(@"dic = %@", dic);
//            [GTAudioUser sharedUserInfo].tvSocketVideoDict = dic;
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TvSocketNotice object:nil];
        } else {
            UILOG(@"json解析失败：%@", err);
        }
    }
}

void CHandleMsg::HandleNewsFlash(MsgPacket &msg)
{
    string strMsg;
    msg >> strMsg;

    //printf("new:%s\n", strMsg.c_str());
//    UILOG(@"new:%s\n", strMsg.c_str());
//    NSString *ocString = [NSString stringWithUTF8String:strMsg.c_str()];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RECIEVE_QUICKMESSAGE object:ocString];
}

void CHandleMsg::HandleCacheNewsFlash(MsgPacket &msg)
{
    string strMsg;
    
    uint32_t iSize;
    msg >> iSize;
    
    //printf("recv cache news: %u", iSize);
    UILOG(@"recv cache news: %u", iSize);
    
    NSMutableArray *cacheArray=[NSMutableArray array];
    
    for (int iIndex = 0; iIndex< iSize; iIndex++)
    {
        msg >> strMsg;
//        printf("cache news: %s", strMsg.c_str());

        NSString *jsonString = [NSString stringWithUTF8String:strMsg.c_str()];
//        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *err;
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                            options:NSJSONReadingMutableContainers
//                                                              error:&err];
//        if (err) {
//            NSLog(@"json解析失败：%@", err);
//            continue;
//        }
        [cacheArray addObject:jsonString];
    }

//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RECIEVE_CACHE_QUICKMESSAGE object:cacheArray];
}

void CHandleMsg::HandleUserTestsMsg(MsgPacket &msg)
{
    string strMsg;
    msg >> strMsg;

    //printf("recv tests msg:%s\n", strMsg.c_str());
    UILOG(@"recv tests msg:%s\n", strMsg.c_str());
}

////同一帐号重复登录,旧的登录被T下线,提示用户,然后断开vip服连接,连接到普通服
void CHandleMsg::HandleMultipleLoginKickOff(MsgPacket &msg)
{
    //printf("vip multiple login kick off\n");
    UILOG(@"vip multiple login kick off\n");
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_VIP_OFFLINE object:nil];
}

//vip过期,提示用户,然后断开vip服连接,连接到普通服
void CHandleMsg::HandleVipExpired(MsgPacket &msg)
{
    //printf("vip expired.");
    UILOG(@"vip expired.");
    //[GTUtil showToastWithMsgBottom:@"您的vip已过期"];
    createSocket();
}

//登录快讯服,参数:用户ID(uint32),token(string),机器标识(string)
void CHandleMsg::sendLogin()
{
//    uint32_t uid = (uint32_t)[GTAccountManager instance].userId.integerValue;
//    string strToken = [[GTAccountManager instance].token UTF8String];
//    string strMachineID = [[GTSubscribeManager instance].deviceUUID UTF8String];
//    MsgPacket msg;
//    msg.InitSendMsg(MSG_USER_LOGIN_NEWS);
//    msg << uid << strToken << strMachineID;
//    m_newsSocket->sendPacket(msg);
}

//登录快讯服返回登录结果
void CHandleMsg::HandleLoginResult(MsgPacket &msg)
{
    string strJson;
    msg >> strJson;

    NSString *jsonString = [NSString stringWithUTF8String:strJson.c_str()];

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        NSLog(@"json解析失败：%@", err);
        return;
    }
//    NSInteger iStatus = [[dic objectForKeySafe:@"status"] integerValue];
//    NSString *strMsg = [dic objectForKeySafe:@"message"];
//    switch (iStatus) {
//        case LOGIN_VIP_SUCCESS:    // = 1,                //vip客户端登陆成功
//        {
//            NSLog(@"%@", strMsg);
//            break;
//        }
//        //以下情况重试
//        case LOGIN_UCENTER_DATA_PARSE_ERR:    //,        //用户中心返回结果解析错误
//        case LOGIN_UCENTER_GET_DATA_ERROR:    //,        //从用户中心获取用户数据失败
//
//        //以下情况连普通服
//        case LOGIN_NOT_VIP_USER:    //,                    //非vip
//        case LOGIN_VIP_EXPIRATION:    //,                //用户vip已过期
//
//        default:
//            break;
//    }
}

#pragma -mark  链接反馈
void CHandleMsg::HandleNewsSocketEvent(MsgPacket &msg)
{
    uint16_t eState;
    msg >> eState;

    string strTag = msg.GetOpcode() == QuoteSocketTag ? "gateway" : "news";

    if (msg.GetOpcode() == NewsSocketTag) m_flashSocketState = eState;
    if (msg.GetOpcode() == QuoteSocketTag) m_quoteSocketState = eState;

    if (eState == eSocketEvent_on_connect) {
        //printf("%s socket connected......................\n", strTag.c_str());
        UILOG(@"%s socket connected......................\n", strTag.c_str());
        
    } else if (eState == eSocketEvent_on_got_key) {//消息加密时此时连接成功
        //printf("%s socket got key......................\n", strTag.c_str());
        UILOG(@"%s socket got key......................\n", strTag.c_str());
        
    } else if (eState == eSocketEvent_on_vierify) {//开启内部验证时连接成功
        //printf("%s socket on vierify......................\n", strTag.c_str());
        UILOG(@"%s socket on vierify......................\n", strTag.c_str());
/*
        if (msg.GetOpcode() == NewsSocketTag) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SOCKET_QUICKMSG_CONNECT_SUCCESS object:nil];
//            if ([GTAccountManager instance].isVip) {
//                sendLogin();
//            }
        }

        if (msg.GetOpcode() == QuoteSocketTag) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SOCKET_MARKET_CONNECT_SUCCESS object:nil];

//            if ([GTAccountManager instance].logined) {
//                uint32_t userId = (uint32_t)[GTAccountManager instance].userId.longLongValue;
//                sendUserId(userId);
//                [[GTStatisticsManager sharedManager] setUserInfo];
//            }

            //请求高级报价
            //            vector<string> vtQuote;
            //            vtQuote.push_back("EURAUD.FXCM");
            //            requestAdvancedQuote(vtQuote,3000);

            //请求K线报价
            //            vector<KlineQuote> vtKline;
            //            vtKline.push_back(KlineQuote("EURAUD.FXCM", QuoteType_MINUTE));
            //            requestKlineQuote(vtKline,3000);

            //请求历史文件信息
            //            requestHistoryFile("EURGBP.NY$", 1, Max_Hisroty_File_Time, 1, -1);

            //请求排行榜
            //            vector<uint16_t> vtSortID;
            //            vtSortID.push_back(1);
            //            requestSort(vtSortID);

            //请求高级预警
            //            STWarn warn;
            //            warn.strCode = "EURAUD.FXCM";
            //            warn.warnID = 12;
            //            warn.warnMore = 1212;
            //            warn.warnLess = 111;
            //
            //            vector<STWarn> vtWarn;
            //            vtWarn.push_back(warn);
            //            requestWarn(vtWarn);
        }
    */
    } else if (eState == eSocketEvent_on_close) {
        //printf("%s socket close......................\n", strTag.c_str());
        
        UILOG(@"%s socket close......................\n", strTag.c_str());
//        if (msg.GetOpcode() == NewsSocketTag) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SOCKET_QUICKMSG_DISCONNECT object:nil];
//        }
//
//        if (msg.GetOpcode() == QuoteSocketTag) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SOCKET_MARKET_DISCONNECT object:nil];
//        }
    }
}

bool CHandleMsg::sendMsg(MsgPacket& msg)
{
    if (m_quoteSocket != nullptr) {
        m_quoteSocket->sendPacket(msg);
        return true;
    } else {
        //printf("socket is null......................\n");
        UILOG(@"socket is null......................\n");
        return false;
    }
}

void CHandleMsg::requestKlineQuote(vector<KlineQuote> vtKline, uint32_t iInverval)
{
    uint16_t iCount = vtKline.size();
    MsgPacket msg;
    msg.InitSendMsg(MSG_REQUEST_STOCK_KLINE);
    msg << iInverval << iCount;

    if (iCount > 0) {
        for (int iIndex = 0; iIndex < iCount; iIndex++) {
            msg << vtKline[iIndex].strCode << vtKline[iIndex].iTime;
        }
    }

    sendMsg(msg);
}

void CHandleMsg::requestAdvancedQuote(vector<string> vtCode, uint32_t iInverval)
{
    uint16_t iCount = vtCode.size();
    MsgPacket msg;
    msg.InitSendMsg(MSG_REQUEST_STOCK_ADVANCED);
    msg << iInverval << iCount;

    if (iCount > 0) {
        for (int iIndex = 0; iIndex < iCount; iIndex++) {
            msg << vtCode[iIndex];
        }
    }

    sendMsg(msg);
}

#pragma -mark 品种名，K线周期， 时间戳，窗口标识（无用0代替），方向（-1向旧的时间方向查询，1向新的时间查询）

//msg << string("EURAUD.FXCM") << uint8_t(1) << uint64_t(time(0)) << uint16_t(5) << int8_t(-1);
void CHandleMsg::requestHistoryFile(const string &strCode, uint8_t itimeType, uint64_t iTime, uint16_t iWinID, int8_t iWay)
{
    MsgPacket msg;
    msg.InitSendMsg(MSG_HISTORY_FILE_NAME);
    msg << strCode << itimeType << iTime << iWinID << iWay;
    sendMsg(msg);
    //     NetCoreMgr::SendMsgBySock(msg, m_quoteSocket);
    //printf("requestHistoryFile-c++---------- \n");
    //UILOG(@"requestHistoryFile-c++---------- \n");
}

void CHandleMsg::HandleRequestHistoryFileCallback(MsgPacket &msg)
{
    string strCode;

    uint16_t iWinID = 0;
    int8_t iCount = 0;
    int8_t iWay = 0;
    uint8_t iTimeType = 0;

    uint64_t iTime = 0;
    vector<string> vtResult;

    msg >> strCode >> iWinID >> iWay >> iTimeType >> iTime >> iCount;

    //printf("historyfile code:%s, winId:%d, way:%d, klineTime:%d, time:%llu, fileCount:%d \n", strCode.c_str(), iWinID, iWay, iTimeType, iTime, iCount);
    
    UILOG(@"historyfile code:%s, winId:%d, way:%d, klineTime:%d, time:%llu, fileCount:%d \n", strCode.c_str(), iWinID, iWay, iTimeType, iTime, iCount);

    string strFileName;

    NSMutableArray *array = [NSMutableArray array];
    if (iCount > 0) {// iCount == 0 :failed,iCount == -1 :no result
        for (int iDx = 0; iDx < iCount; iDx++) {
            msg >> strFileName;
            vtResult.push_back(strFileName);
            //            printf("history file:%s", strFileName.c_str());

            [array addObject:[NSString stringWithUTF8String:strFileName.c_str()]];
        }
    }
    // 先返回文件序号大的 旧的
    //文件名字.文件数量。开始时间。结束时间。文件id
    //c6bc51f8b643fe2b0cef934eebd3a058.357.1541996640.1542018000.12034
    //    f9ef60b9da3e30374615c0a20faa457e.500.1541965980.1541996580.12033
    NSString *codeWithEX = [NSString stringWithUTF8String:strCode.c_str()];
    //[[JTQuotesManager shareInstance] receiveHistory:array codeWithEX:codeWithEX timeType:iTimeType];
}


#pragma mark 不断下发K线报价
void CHandleMsg::HandleKlineQuote(MsgPacket &msg)
{
    string strCode;
    int iTimeType;
    S_KLine s_kline;
    msg >> strCode >> iTimeType;

    msg.read((uint8_t *)(&s_kline), sizeof(s_kline));
    KLine kline(s_kline);//转换成小数,默认6位

    //printf("K:%s.%d => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), iTimeType, s_kline.iTime, s_kline.fOpen, s_kline.fHight, s_kline.fLow, s_kline.fClose);
    //UILOG(@"K:%s.%d => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), iTimeType, s_kline.iTime, s_kline.fOpen, s_kline.fHight, s_kline.fLow, s_kline.fClose);
    
    NSString *codeWithEX = [NSString stringWithUTF8String:strCode.c_str()];
//    [[GTMarketManager sharedManager] receiveKlineQuote:kline codeWithEX:codeWithEX timeType:iTimeType];
}

#pragma -mark  高级报价
void CHandleMsg::HandleAdvancedQuote(MsgPacket &msg)
{
    string strCode;
    msg >> strCode;
    S_AdvancedQuote advQuote;

    msg.read((uint8_t *)(&advQuote), sizeof(S_AdvancedQuote));

    //printf("A:%s => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), advQuote.iCurPrice, advQuote.iHigh, advQuote.iOpen, advQuote.iLow, advQuote.iHstClose);
    //UILOG(@"A:%s => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), advQuote.iCurPrice, advQuote.iHigh, advQuote.iOpen, advQuote.iLow, advQuote.iHstClose);
    
    AdvancedQuote quote(advQuote);
    NSString *codeWithEX = [NSString stringWithUTF8String:strCode.c_str()];
    //[[JTQuotesManager shareInstance] receiveAdvancedQuote:quote codeWithEX:codeWithEX];
}

void CHandleMsg::HandleRequestKlineCallbck(MsgPacket &msg)
{
    uint16_t iCount;
    msg >> iCount;
    //printf("request kline:%d\n", iCount);
    UILOG(@"request kline:%d\n", iCount);
}

void CHandleMsg::HandleRequestAdvancedCallback(MsgPacket &msg)
{
    uint16_t iCount;
    msg >> iCount;
    //printf("request advanced:%d\n", iCount);
    UILOG(@"request advanced:%d\n", iCount);
}

void CHandleMsg::HandleChangePhaseCode(MsgPacket &msg)
{
    string strCode = "";
    string phaseCode = "";
    msg >> strCode >> phaseCode;

    //printf("%s trading phase code changed:%s\n", strCode.c_str(), phaseCode.c_str());
    UILOG(@"%s trading phase code changed:%s\n", strCode.c_str(), phaseCode.c_str());
}

void CHandleMsg::requestSort(vector<uint16_t> &vtSortID)
{
    uint16_t iSize = vtSortID.size();

    MsgPacket msg;
    msg.InitSendMsg(MSG_REQUEST_SORT_LIST);
    msg << iSize;

    for (int iIndex = 0; iIndex < iSize; iIndex++) {
        msg << vtSortID[iIndex];
    }

    sendMsg(msg);
    //     NetCoreMgr::SendMsgBySock(msg, m_quoteSocket);
}

void CHandleMsg::HandleRequestSortCallback(MsgPacket &msg)
{
    uint16_t iCount;
    uint32_t iTime;

    msg >> iCount >> iTime;

    //printf("requestSortListCallback count:%d, time:%u\n", iCount, iTime);
    UILOG(@"requestSortListCallback count:%d, time:%u\n", iCount, iTime);
}

void CHandleMsg::HandleSort(MsgPacket &msg)
{
    uint16_t iSize;
    uint16_t iID;

    string strCodeMarket;

    int iAmplitude;
    int iRiseFallPercent;
    uint64_t iCurPrice;

    msg >> iID >> iSize;

    //printf("sort:%d,count:%d\n", iID, iSize);
    UILOG(@"sort:%d,count:%d\n", iID, iSize);

    SortIDVector vtItem;
    SortIDVector vtRiseItem;
    SortIDVector vtFallItem;
    SortItemInfo itemInfo;

    for (int iIndex = 0; iIndex < iSize; iIndex++) {
        msg >> strCodeMarket >> iCurPrice >> iRiseFallPercent >> iAmplitude;

        itemInfo.m_strCodeMarket = strCodeMarket;
        itemInfo.m_fCurPrice = iCurPrice * Ratio_Number;
        itemInfo.m_fRiseFallPercent = iRiseFallPercent * 0.01f;
        itemInfo.m_fAmplitude = iAmplitude * 0.01f;

        //printf("up:%s,%llu, %d, %d\n", strCodeMarket.c_str(), iCurPrice, iRiseFallPercent, iAmplitude);
        vtItem.push_back(itemInfo);
        vtRiseItem.push_back(itemInfo);
    }

    msg >> iSize;
    for (int iIndex = 0; iIndex < iSize; iIndex++) {
        msg >> strCodeMarket >> iCurPrice >> iRiseFallPercent >> iAmplitude;

        itemInfo.m_strCodeMarket = strCodeMarket;
        itemInfo.m_fCurPrice = iCurPrice * Ratio_Number;
        itemInfo.m_fRiseFallPercent = iRiseFallPercent * 0.01f;
        itemInfo.m_fAmplitude = iAmplitude * 0.01f;

        vtItem.push_back(itemInfo);
        vtFallItem.push_back(itemInfo);

        //printf("down:%s,%llu, %d, %d\n", strCodeMarket.c_str(), iCurPrice, iRiseFallPercent, iAmplitude);
    }
}

void CHandleMsg::HandleSortTypeList(MsgPacket &msg)
{
    uint16_t iCount;
    msg >> iCount;

    uint16_t iID;
    string strName;

    unordered_map<uint16_t, string> mapTemp;

    for (int iIndex = 0; iIndex < iCount; iIndex++) {
        msg >> iID >> strName;
        mapTemp[iID] = strName;
        //printf("sort list:%d = %s\n", iID, strName.c_str());
        UILOG(@"sort list:%d = %s\n", iID, strName.c_str());
    }
}

void CHandleMsg::HandleWarn(MsgPacket &msg)//高级预警响应
{
    string strCode;
    uint32_t iWarnID;
    msg >> strCode >> iWarnID;

    S_AdvancedQuote advQuote;
    msg.read((uint8_t *)(&advQuote), sizeof(S_AdvancedQuote));

    //printf("warn:%s[%d] => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), iWarnID, advQuote.iCurPrice, advQuote.iHigh, advQuote.iOpen, advQuote.iLow, advQuote.iHstClose);
    UILOG(@"warn:%s[%d] => %llu,%llu,%llu,%llu,%llu\n", strCode.c_str(), iWarnID, advQuote.iCurPrice, advQuote.iHigh, advQuote.iOpen, advQuote.iLow, advQuote.iHstClose);
}

S_KLine * CHandleMsg::parseHistoryKLine(unsigned char *_pData, unsigned int _iFileSize, uint32_t &iSize)
{
    if (_pData == nullptr || _iFileSize == 0) return nullptr;

    S_KLine *sKline = nullptr;
    const int klineSize = sizeof(S_KLine);

    iSize = _iFileSize / klineSize;
    return (S_KLine *)_pData;

    //    int iIndex = 0;
    //    while (iIndex < _iFileSize)
    //    {
    //        sKline = (S_KLine *)(_pData + iIndex);
    //        vtResult.push_back(KLine(*sKline));
    //        iIndex += klineSize;
    //    }
    //
    //
    //
    //    return (uint32_t)vtResult.size();
}


#pragma mark 第一次下发K线报价 下发10条
void CHandleMsg::HandleFirstKline(MsgPacket &msg)
{
    string strCode;
    int8_t iTimeType;
    uint32_t iCount;

    msg >> strCode >> iTimeType >> iCount;

//    if (iCount > 0) {
//        JTKLine *newKline = new JTKLine[iCount];
//        S_KLine s_kline;
//
//        for (int iIndex = 0; iIndex < iCount; iIndex++) {
//            msg.read((uint8_t *)(&s_kline), sizeof(s_kline));
//            newKline[iIndex] = KLine(s_kline);
//        }
//
//        NSString *codeWithEX = [NSString stringWithUTF8String:strCode.c_str()];
//        [[JTQuotesManager shareInstance] receiveKlineRecentlyQuote:newKline Count:iCount codeWithEX:codeWithEX timeType:iTimeType];
//
//        delete [] newKline;
//        newKline = nullptr;
//    } else {
//        NSString *codeWithEX = [NSString stringWithUTF8String:strCode.c_str()];
//        [[JTQuotesManager shareInstance] receiveKlineRecentlyQuote:nil Count:0 codeWithEX:codeWithEX timeType:iTimeType];
//    }

}

//预警相关操作///////////////////////////////////
/*
 预警有两种：时间预警和价格预警，如果设置了预警时间则为时间预警（此时间再设置价格无效）
 socket 验证成功后需要马上发送用户ID到gateway以请求预警列表,参考180行
 用户在线时如果预警触发通过socket发送，不在线时通过消息推送.
 */
void CHandleMsg::warnOperation(STWarn &warn, uint16_t code)
{
    MsgPacket msg;
    msg.InitSendMsg(MSG_WARN_OPEARTION);
    msg << code;
    warn.write(msg);

    m_quoteSocket->sendPacket(msg);
}

void CHandleMsg::SetWarn(STWarn &warn)//添加/修改预警
{
    MsgPacket msg;
    msg.InitSendMsg(MSG_WARN_OPEARTION);
    warnOperation(warn, WarnCodeSet);
}

void CHandleMsg::deleteWarn(vector<uint32_t>& vtID, uint32_t iUID) //删除预警
{
    //warnOperation(warn, WarnCodeDel);
    uint16_t iCount = vtID.size();
    MsgPacket msg;
    msg.InitSendMsg(MSG_WARN_OPEARTION);
    msg << WarnCodeDel << iUID << iCount;
    for (int iIndex = 0; iIndex < iCount; iIndex++) {
        msg << vtID[iIndex];
    }
    m_quoteSocket->sendPacket(msg);
}

void CHandleMsg::clearWarn(uint32_t iUID)//清空所有预警
{
    MsgPacket msg;
    msg.InitSendMsg(MSG_WARN_OPEARTION);
    msg << WarnCodeDelUser << iUID;

    m_quoteSocket->sendPacket(msg);
}

int CHandleMsg::AddWarn(STWarn &warn)//添加一个预警，返回新预警ID
{
    if (!m_bGotWarnList) return -1; //未得到预警列表（未连接成功）
    uint32_t iMAXID = 0;
    for (int iIndex = 0; iIndex < m_vtWarn.size(); iIndex++) {
        if (m_vtWarn[iIndex].warnID > iMAXID) iMAXID = m_vtWarn[iIndex].warnID;
    }

    iMAXID++;
    warn.warnID = iMAXID;
    m_vtWarn.push_back(warn);

    //printf("add warnid:%u,state:%d,code:%s,time:%u,more:%llu,less:%llu\n", warn.warnID, warn.iState, warn.strCodeMarket.c_str(), warn.warnTime, warn.warnMore, warn.warnLess);

    UILOG(@"add warnid:%u,state:%d,code:%s,time:%u,more:%llu,less:%llu\n", warn.warnID, warn.iState, warn.strCodeMarket.c_str(), warn.warnTime, warn.warnMore, warn.warnLess);
    
    return iMAXID;
}

void CHandleMsg::HandleWarnOperation(MsgPacket &msg)//请求预警结果
{
    uint16_t iCode;
    msg >> iCode;
//    switch (iCode) {
//        case WarnCodeGetList://预警列表
//        {
//            m_bGotWarnList = true;
//            uint16_t iCount;
//            msg >> iCount;
//            printf("warn list count:%d\n", iCount);
//            [GTMarketManager sharedManager].warnListArray = [NSMutableArray array];
//            for (int iIndex = 0; iIndex < iCount; iIndex++) {
//                STWarn warn(msg);
//                m_vtWarn.push_back(warn);
//
//                printf("warnid:%u,state:%d,code:%s,time:%u,more:%llu,less:%llu\n", warn.warnID, warn.iState, warn.strCodeMarket.c_str(), warn.warnTime, warn.warnMore, warn.warnLess);
//                NSString *codeWithEX = [NSString stringWithUTF8String:warn.strCodeMarket.c_str()];
//                GTWarnModel *model = [[GTWarnModel alloc] init];
//                model.warnID = warn.warnID;
//                model.iState = warn.iState;
//                model.codeWithEx = codeWithEX;
//                model.warnTime = warn.warnTime;
//                model.warnMore = warn.warnMore;
//                model.warnLess = warn.warnLess;
//                [[GTMarketManager sharedManager].warnListArray addObject:model];
//
//                //                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RECIEVE_WARN_LIST object:[GTMarketManager sharedManager].warnListArray];
//            }
//
//            break;
//        }
//        case WarnCodeSet://添加修改预警
//        {
//            uint16_t iResult;
//            uint32_t iWarnID;
//            msg >> iResult;
//            STWarn warn(msg);
//            printf("set warn:%d,%u\n", iResult, warn.warnID);
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RECEIVE_MARKET_WARN_ADD object:@(iResult)];
//            if (iResult == 1) {
//                NSString *codeWithEX = [NSString stringWithUTF8String:warn.strCodeMarket.c_str()];
//                GTWarnModel *model = [[GTWarnModel alloc] init];
//                model.warnID = warn.warnID;
//                model.iState = warn.iState;
//                model.codeWithEx = codeWithEX;
//                model.warnTime = warn.warnTime;
//                model.warnMore = warn.warnMore;
//                model.warnLess = warn.warnLess;
//                [[GTMarketManager sharedManager].warnListArray addObject:model];
//            }
//            break;
//        }
//        case WarnCodeDel://删除预警
//        {
//            uint32_t iWarnID;
//            uint16_t iResult;
//            msg >> iResult >> iWarnID;
//            printf("del warn:%u result:%d\n", iWarnID, iResult);//1操作成功，其它失败
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RECEIVE_MARKET_WARN_DEL object:@(iResult)];
//            break;
//        }
//        case WarnCodeDelUser://删除所有预警
//        {
//            uint16_t iResult;
//            msg >> iResult;
//            printf("clear warn result:%d\n", iResult);//1操作成功，其它失败
//            break;
//        }
//        case WarnCodeTrigger://预警触发（在线时）
//        {
//            STWarn warn(msg);
//            if (warn.warnTime == 0) {//price warn
//                S_AdvancedQuote advQuote;
//                msg.read((uint8_t *)(&advQuote), sizeof(S_AdvancedQuote));
//
//                printf("trigger price warn:%s[%d] => %llu,%llu,%llu,%llu,%llu\n", warn.strCodeMarket.c_str(), warn.warnID, advQuote.iCurPrice, advQuote.iHigh, advQuote.iOpen, advQuote.iLow, advQuote.iHstClose);
//            } else {
//                printf("trigger time warn:%u => %u\n", warn.warnID, warn.warnTime);
//            }
//            break;
//        }
//        default:
//            break;
//    }
}

void CHandleMsg::sendUserId(uint32_t uid)//发送用户id
{
    m_bGotWarnList = false;
    m_vtWarn.clear();

    //登录成功必须先发送用户ID
    MsgPacket newMsg;
    newMsg.InitSendMsg(MSG_SEND_USERID_TO_GATEWAY);
    newMsg << uid;
    if (m_quoteSocket != nullptr) {
        m_quoteSocket->sendPacket(newMsg);
    }
}
