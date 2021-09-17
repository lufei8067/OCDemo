
//
//  SessionInfo.h
//  
//  Created by qiyun on 18-11-12.
//  Copyright (c) 2018 __jin10.com__. All rights reserved.
//

#ifndef __SessionInfo_h__
#define __SessionInfo_h__

//#include "../common/common.h"
#include "libs/netcore/include/MsgPacket.h"
using namespace std;

/*按钮ID分配规则:
取值范围为uint32, 0 - 4294967295,每个主要页面分配1000,000的区间
快讯页面的按钮ID区间为 1 至 1000,000
参考页面的按钮ID区间为 1000,001 至 2000,000
行情页面的按钮ID区间为 2000,001 至 3000,000
日历页面的按钮ID区间为 3000,001 至 4000,000
数据页面的按钮ID区间为 4000,001 至 5000,000

用户页面的按钮ID区间为 5000,001 至 6000,000
直播页面的按钮ID区间为 6000,001 至 7000,000
电台页面的按钮ID区间为 7000,001 至 8000,000
英雄说页面的按钮ID区间为 8000,001 至 9000,000

内部按钮自由分配,但IOS,android 须一致

入口按钮使用区间第一个ID,如:
快讯按钮的ID为1,
参考按钮的ID为1000,001,
行情按钮的ID为2000,001,
日历按钮的ID为3000,001,
数据按钮的ID为4000,001
*/


//会话类型
enum SessionType
{
	eSessionType_null = 0,			//空
	eSessionType_register,			//注册
	eSessionType_login,				//登陆
	eSessionType_selectFunc,		//进入功能(快讯,参考,行情,日历,数据,用户页面,直播,电台,英雄说)

	eSessionType_exitGroup,			//编辑栏目分类

	eSessionType_readNews,			//阅读快讯
	eSessionType_readNewsZhu,		//阅读金十注
	eSessionType_selectGroup,		//选择功能分类,如:快讯的期货类型

	eSessionType_reference,			//查看参考
	eSessionType_market,			//查看行情
	eSessionType_addStockFav,		//添加品种到自选
	eSessionType_addWarn,			//添加品种预警

	eSessionType_calendar,			//查看日历
	eSessionType_calendarFilter,	//设置日历筛选
	eSessionType_calendarRemind,	//添加日历提醒
	eSessionType_viewCalenderGroup,	//查看日历分类

	eSessionType_dataCenter,		//查看数据中心


	eSessionType_listenRadio,		//收听电台
	eSessionType_watchLive,			//收看直播
	eSessionType_watchReplay,		//收看回放
	eSessionType_subscriber,		//订阅

	eSessionType_addFavorite,		//添加到收藏
	eSessionType_search,			//搜索
	eSessionType_comment,			//评论/回复
	eSessionType_publish,			//发布


	eSessionType_share,				//用户分享
	eSessionType_modifyInfo,		//修改用户信息
	eSessionType_userFunc,			//点击用户界面功能

	eSessionType_feedback,			//提交用户反馈
	eSessionType_questionnaire,		//提交调查问卷


	eSessionType_background,		//应用后台(手机端)
	eSessionType_crash,				//应用崩溃/异常

	eSessionType_goodReview,		//用户给app好评
	eSessionType_clickAD,			//点击了推广广告

	eSessionType_logout,			//注销
	eSessionType_exit,				//退出(关闭)
};


//每个操作节点(点击按钮)或每2分钟划分为一个会话session
//4W1H 模型：Who、When、Where、How、What)
struct STSession
{
	uint32_t	iTime;				//when
	uint32_t    iUserID;			//who
	uint32_t	iTargetD;			//where(控件ID)

	uint8_t		iSessionType;		//what(SessionType)
	string		strData;			//附加数据(json)

	STSession() :iTime(0), iUserID(0), iTargetD(0), iSessionType(eSessionType_null) {}
	STSession(ByteBuffer &buff) { readFormBuff(buff); }
	void writeToBuffer(ByteBuffer &buff)
	{
		buff << iTime << iUserID << iTargetD << iSessionType << strData;
	}
	void readFormBuff(ByteBuffer &buff)
	{
		buff >> iTime >> iUserID >> iTargetD >> iSessionType >> strData;
	}

};


//会话管理器
class SessionMgr
{
public:
	static SessionMgr & getinstance() { static SessionMgr s_inst; return s_inst; }

	void				setUserInfo(uint32_t uid, uint32_t maxCache);//设置用户信息:uid用户ID, maxCache缓存会话数量

	void				addSession(uint16_t targetID, SessionType sessionT, const string &strData);
	int					sendSession();		//发送缓存中的会话
	void				clearSession();		//清空缓存中的会话

	void TestJson();

protected:

	vector<STSession>	m_vtSession;		//按操作步骤收集的会话
	uint32_t			m_iUUID;			//用户ID
	uint32_t			m_iCacheSession;	//会话数>=此数时发送

private:

	SessionMgr() :m_iUUID(0), m_iCacheSession(5) {}
	~SessionMgr() {}

};

#define SessionMgrInst SessionMgr::getinstance()

#endif // !__SessionInfo_h__
