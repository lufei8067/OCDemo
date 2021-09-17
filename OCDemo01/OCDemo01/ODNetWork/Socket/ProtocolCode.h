//
//  ProtocolCode
//  appsocket
//
//  Created by qiyun on 2018/10/31.
//  Copyright © 2018年 qiyun. All rights reserved.
//

namespace ProtocolCode
{
    enum APP_LOGIN_RESULT {
        LOGIN_VIP_SUCCESS = 1,                       //vip客户端登陆成功
        LOGIN_NOT_VIP_USER,                          //非vip

        LOGIN_UCENTER_DATA_PARSE_ERR,                //用户中心返回结果解析错误
        LOGIN_UCENTER_GET_DATA_ERROR,                //从用户中心获取用户数据 失败
        LOGIN_VIP_EXPIRATION,                        //用户vip已过期

        LOGIN_ERR_PARAM_WRONG,                       // 参数有误

        LOGIN_ERR_UNKNOW = 199,                      // 未知错误
        LOGIN_OPCODE_200 = 200,                      //操作成功
    };

    enum MsgCode {
        //quoteNode
        MSG_CLIENT_TO_QUOTENODE_BEGIN    = 10000,//客户端到 报价服的协议区间 =======begin============

        MSG_REQUEST_STOCK_KLINE          = 10002, //请求品种K线报价
        MSG_REQUEST_STOCK_ADVANCED       = 10003, //请求高级报价

        MSG_KLINE_QUOTE                  = 10004, //下发K线报价(跳动)
        MSG_ADVANCED_QUOTE               = 10005, //下发高级报价
        MSG_HISTORY_FILE_NAME            = 10006, //下发历史数据文件查找结果
        MSG_FIRST_KLINE_QUOTE            = 10007, //第一次下发K线报价
        MSG_CHANGE_PHASE_CODE            = 10008, //品种状态改变

        MSG_REQUEST_SORT_LIST            = 10009, //请求涨跌榜
        MSG_SEND_SORT_LIST               = 10010, //下发涨跌榜
        MSG_REQUEST_STOCK_DAY_LINE       = 10011, //请求品种日走势线

        MSG_REQUEST_SORT_TYPE_LIST       = 10012, //请求/下发涨跌榜类型列表
        MSG_REQUEST_WARNNING             = 10013, //请求高级预警
        MSG_WARN_OPEARTION               = 10017, //预警相关操作
        MSG_SEND_USERID_TO_GATEWAY       = 10018, //验证成功发送用户ID到gateway

        MSG_CLIENT_TO_QUOTENODE_END      = 20000, //客户端到 报价服的协议区间 ======end==============
        //////////////////////////////////////////////////////////////////////////
        MSG_NEWS_FLASH                   = 1000,  //下发快讯
        MSG_EVENT_FLASH                  = 1001,  //下发事件
        MSG_VIP_NEWS_FLASH               = 1100,  //vip快讯
        MSG_SEND_CACHE_NEWS              = 1200,//连接成功后下发缓存的快讯
        MSG_USER_LOGIN_NEWS              = 4002,  //用户登录快讯
        MSG_SEND_USER_VIP_EXPIRED        = 4003,  //通知用户VIP已过期
        MSG_USER_MULTIPLE_LOGIN_KICK_OFF = 4004,    //同一帐号重复登录,旧的登录被T下线

        MSG_USER_TEST_MSG                = 50006, //客户端发送测试信息

        MSG_SEND_SESSION_INFO            = 50010, //客户端发送会话信息
        MSG_SEND_SESSION_INFO_RESULT     = 50011, //处理会话信息结果
    };
    const uint16_t WarnCodeGetList = 1;//请求预警列表
    const uint16_t WarnCodeSet = 2;//添加/修改预警列表
    const uint16_t WarnCodeDel = 3;//删除预警
    const uint16_t WarnCodeDelUser = 4;//删除用户所有预警
    const uint16_t WarnCodeTrigger = 5;//预警触发
}
