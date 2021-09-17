
//
//  SessionInfo.cpp
//  
//  Created by qiyun on 18-11-12.
//  Copyright (c) 2018 __jin10.com__. All rights reserved.
//
#include "SessionMgr.h"
#include "HandleMsg.h"
#include "ProtocolCode.h"


using namespace ProtocolCode;


#define VS_Project 0

#if VS_Project
#include "../common/jsonc11/json11.hpp"
using namespace json11;
#endif

void SessionMgr::setUserInfo(uint32_t uid, uint32_t maxCache)
{
	m_iUUID = uid;
	m_iCacheSession = maxCache;
}

void SessionMgr::addSession(uint16_t targetID, SessionType sessionT, const string &strData)
{
	STSession session;
	session.iTime = time(0);
	session.iUserID = m_iUUID;
	session.iTargetD = targetID;
	session.iSessionType = sessionT;
	session.strData = strData;

	m_vtSession.push_back(session);

	if (m_vtSession.size() >= m_iCacheSession)
	{
		sendSession();
	}
}

int SessionMgr::sendSession()
{
	uint16_t iSize = m_vtSession.size();
	if (iSize > 0)
	{
		uint64_t iUserEntityID = 0;//点位用
		MsgPacket msg;
		msg.InitSendMsg(MSG_SEND_SESSION_INFO);
		msg << iUserEntityID << iSize;

		for (int iIndex = 0; iIndex < iSize; iIndex++)
		{
			m_vtSession[iIndex].writeToBuffer(msg);
		}

		//TODO send msg......
        CHandleMsg::getInstance().sendMsg(msg);
        m_vtSession.clear();
		return iSize;
	}

	return 0;
}

void SessionMgr::clearSession()
{
	m_iUUID = 0;
	m_vtSession.clear();
}


void SessionMgr::TestJson()
{

#if VS_Project


	//eSessionType_register,注册
	Json regJson = Json::object{
		{ "channel", "360" },//安装途径
		{ "platform", "android" },//手机平台
		{ "osVer", "8.1" },//os版本
		{ "model", "xiao mi 6" },//手机型号
		{ "appVer", "1.0.0" },//app版本
		{ "deviceID", "3532523662412" },//机器唯一标识
		{ "phoneNumber", "13562532533" },//手机号
		{ "resolution", "1080*1920" },//手机分辨率
		{ "local",Json::object{
			{ "province" , "guangdong" },//省份
			{ "city" , "guangzhou" },//所在城市
			{ "district","zhuhai" },//城区
			{ "street" , "jiangbei" },//街道
			{ "lat" , "37.0" },//纬度
			{ "lng" , "39.0" } } }//经度
	};

	//eSessionType_login,登陆
	Json loginJson = Json::object{
		{ "accountType", "guest" },//帐号类型,guest游客,register注册用户
		{ "onOldDevice", true }, }; //是否在之前的设备登陆,如果不是则需要补全以下信息
		/*{ "channel", "360" },//安装途径
		{ "platform", "android" },//手机平台
		{ "osVer", "8.1" },//os版本
		{ "model", "xiao mi 6" },//手机型号
		{ "appVer", "1.0.0" },//app版本
		{ "deviceID", "3532523662412" },//机器唯一标识
		{ "phoneNumber", "13562532533" },//手机号
		{ "resolution", "1080*1920" },//手机分辨率
		{ "local", Json::object{
		{ "province" , "guangdong" },//省份
		{ "city" , "guangzhou" },//所在城市
		{ "district","zhuhai" },//城区
		{ "street" , "jiangbei" },//街道
		{ "lat" , "37.0" },//纬度
		{ "lng" , "39.0" } } },//经度
		};*/

	//eSessionType_selectFunc,进入功能
	Json pageJson = Json::object{
		{ "type", "行情" } }; //功能标签,如快讯,参考,行情,日历,数据,用户信息,直播,电台,英雄说等

	//eSessionType_exidGroup,编辑栏目分类
	Json editGroupJson = Json::object{
		{ "type", "快讯" },//类型:快讯,参考,行情等
		{ "groups", json11::Json::array{"综合","主站","期货","美港股","A股"} } };//排序后的栏目

	//eSessionType_readNews,阅读快讯
	Json readNewsJson = Json::object{
		{ "id", "123456" },//快讯ID
		{ "type", "行情" }, //快讯主标签
		{ "groups", "期货" } }; //快讯分类

	//eSessionType_readNewsZhu,阅读金十注
	Json readNewsZhuJson = Json::object{
		{ "id", "123456" },//快讯ID
		{ "type", "期货" }, //快讯类型
		{ "zhuid", "123456" },//注ID
		{ "zhuType", 1 }, };//注类型:1文字,2行情,3连接,4视频,5图文


	//eSessionType_selectGroup,选择功能分类,如 快讯的期货类型
	Json enterGroupJson = Json::object{
		{ "type", "快讯" },//类型:快讯,参考,行情等
		{ "group", "期货" } };//选择的分类

	//eSessionType_reference,查看参考
	Json referenceJson = Json::object{
		{ "id", "123456" },//参考ID或连接
		{ "group", "期货" } };//参考分类

	//eSessionType_market,查看行情
	//eSessionType_addStockFav,	添加自选
	//eSessionType_addWarn,添加品种预警
	Json stockJson = Json::object{
		{ "code", "EURUSD" },	//代码
		{ "group", "外汇" },//类型
		{ "exchange", "FXCM" } };//交易所

	//eSessionType_calendar,查看日历
	Json calendarJson = Json::object{
		{ "id", "123456" },//日历ID
		{ "type", "数据" }, //日历类型:数据,事件,假期
		{ "groups", "财经日历" } }; //日历分类

	//eSessionType_calendarFilter,设置日历筛选
	Json calendarFilterJson = Json::object{
		{ "important", 1 },	//是否只看主要
		{ "status", 1 },//状态:1全部,2已公布,3未公布
		{ "region", json11::Json::array{"美国","法国","日本"} },
		{ "star",3 }//重要程度
	};

	//eSessionType_calendarRemind,添加日历提醒
	Json calendarRemindJson = Json::object{
		{ "id", "123456" },	//日历ID
	};

	//eSessionType_viewCalenderGroup,查看日历分类
	Json viewGroupJson = Json::object{
		{ "group", "财经日历" },	//日历分类:财经日历,美股财报,港股财报,期货财报
	};

	//eSessionType_dataCenter,查看数据中心



	//eSessionType_listenRadio,		//收听电台
	Json radioJson = Json::object{
		{ "group","直播" },//分类:直播,交易早餐,金十财知道,读财经 等......
		{ "anchor", "主播姓名" },//主播姓名
	};

	//eSessionType_watchLive,		//收看直播
	//eSessionType_watchReplay,		//收看回放
	Json liveJson = Json::object{
		{ "group","金十TV" },//分类:金十TV,同声传译,交易学院 等......
		{ "anchor", "主播姓名" },//主播姓名
		{ "showName", "前瞻行情" },//节目名
		{ "replay", 0 },//是否直播,0直播,1回放
	};

	//eSessionType_subscriber,		//订阅
	Json subscriberJson = Json::object{
		{ "group","视频" },//分类:视频,......
		{ "anchor", "主播姓名" },//主播姓名
	};

	//eSessionType_addFavorite,		//添加到收藏
	Json addFavJson = Json::object{
		{ "group","文章" },//分类:视频,文章,朋友圈热文,大佬动态等......
		{ "anchor", "作者" },//作者姓名
		{ "tag","标签" }
	};

	//eSessionType_search,			//搜索
	Json searchJson = Json::object{
		{ "group","快讯" },//分类:快讯,参考,行情,文章,视频,电台 等......
		{ "word", "美元" },//输入的搜索词
	};

	//eSessionType_comment,			//评论/回复
	Json commentJson = Json::object{
		{ "id","12345" },//目标ID或连接
		{ "group","快讯" },//分类:快讯,参考,行情,文章,视频,电台 等......
	};


	//eSessionType_publish,			//发布
	Json publishJson = Json::object{
		{ "id","12345" },//目标ID或连接
		{ "group","快讯" },//分类:快讯,参考,行情,文章,视频 等......
		{ "tag", json11::Json::array{"商品","黄金","做多"} },//关键字
	};



	//eSessionType_share,				//用户分享
	Json shareJson = Json::object{
		{ "id","12345" },//目标ID或连接
		{ "group","快讯" },//分类:快讯,参考,行情,文章,视频,app等......
	};

	//eSessionType_modifyInfo,		//修改用户信息
	//empty

	//eSessionType_userFunc,			//点击用户界面功能
	Json userFuncJson = Json::object{
		{ "type","我的收藏" },//分类:我的收藏,我的评论,我的点赞,推送历史,英雄说,直播,电台,周话题,竟猜 等......
	};


	//eSessionType_feedback,			//提交用户反馈
	Json feedbackJson = Json::object{
		{ "id", "12345" },//反馈ID
		{ "group","界面" },//分类:使用问题,界面,吐槽,需求等......
	};

	//eSessionType_questionnaire,		//提交调查问卷
	Json uestionnaireJson = Json::object{
		{ "id", "12345" },//问卷ID
	};

	//eSessionType_background,			//应用后台(手机端)
	//empty

	//eSessionType_crash,				//应用崩溃/异常
	Json crashJson = Json::object{
		{ "channel", "360" },//安装途径
		{ "platform", "android" },//手机平台
		{ "osVer", "8.1" },//os版本
		{ "model", "xiao mi 6" },//手机型号
		{ "appVer", "1.0.0" },//app版本
		{ "deviceID", "3532523662412" },//机器唯一标识
		{ "phoneNumber", "13562532533" },//手机号
		{ "resolution", "1080*1920" },//手机分辨率
		{ "info", "简要描述" },//描述崩溃/异常 的简要信息

	};

	//eSessionType_goodReview,		//用户给app好评
	Json starJson = Json::object{
		{ "star", 5 },//星级
	};

	//eSessionType_clickAD,			//点击了推广广告
	Json adJson = Json::object{
		{ "id", "12345" },//广告ID或连接
	};

	//eSessionType_logout,			//注销
	//empty


	//eSessionType_exit,			//退出(关闭)
	//empty

#endif

}
