//
//  Kline
//
//  Created by qiyun on 16-11-25.
//  Copyright (c) 2016 __jin10.com__. All rights reserved.
//

#ifndef __Kline_h__
#define __Kline_h__

#define  Ratio_Number  0.000001
#include <string>
#include <map>
#include<unordered_map>
#include "MsgPacket.h"
//#include "usr/include/Objc/NSObject.h"

struct S_KLine
{
    uint64_t iTime;
    uint64_t fHight;
    uint64_t fOpen;
    uint64_t fLow;
    uint64_t fClose;
    uint64_t iSize;
};

struct KLine
{
    uint32_t iTime;
    float fHight;
    float fOpen;
    float fLow;
    float fClose;
    uint64_t iSize;
    
    KLine() :fHight(0), fOpen(0), fLow(0), fClose(0), iSize(0), iTime(0)
    {
        
    }
    
    KLine(int fH, int fO, int fL, int fC, int iS, int iT)
    :fHight(fH), fOpen(fO), fLow(fL), fClose(fC), iSize(iS), iTime(iT)
    {
        
        
    }
    
    
    
    KLine & operator =(const KLine &other)
    {
        this->iTime = other.iTime;
        this->fHight = other.fHight;
        this->fOpen = other.fOpen;
        this->fLow = other.fLow;
        this->fClose = other.fClose;
        this->iSize = other.iSize;
        
        return *this;
    }
    
    KLine(const S_KLine & kline )
    {
        iTime = kline.iTime;
        fHight = kline.fHight * Ratio_Number;
        fOpen = kline.fOpen * Ratio_Number;
        fLow = kline.fLow * Ratio_Number;
        fClose = kline.fClose * Ratio_Number;
        iSize = kline.iSize;
    }
};



//高级报价

struct S_AdvancedQuote
{
    int64_t iCurPrice;//最新成交价-
    int64_t iBidPrice;//买价
    int64_t iAskPrice;//卖价
    
    int64_t iValue;//成交量
    
    
    int64_t iHigh;//最高价
    int64_t iOpen;//开盘价
    int64_t iLow;//最低价
    int64_t iHstClose;//昨收盘
    uint64_t iDollarExchange;//美元汇率
    
};


//高级报价
struct AdvancedQuote
{
    float iCurPrice;//最新成交价-
    float iBidPrice;//买价
    float iAskPrice;//卖价
    
    int64_t iValue;//成交量
    
    float iHigh;//最高价
    float iOpen;//开盘价
    float iLow;//最低价
    float iHstClose;//昨收盘
    
    float iRiseFall; //涨跌: 当前价 - 昨结
    float iRiseFallPercent;//幅度: (当前价 - 昨结)/当前价 * 100
    uint64_t iDollarExchange;//美元汇率
    
    AdvancedQuote()
    {
        iCurPrice = 0;//最新成交价-
        iValue = 0;//成交量
        
        iBidPrice = 0;//买价
        iAskPrice = 0;//卖价
        iHigh = 0;//最高价
        iOpen = 0;//开盘价
        iLow = 0;//最低价
        iHstClose = 0;//昨结
        
        iRiseFall = 0; //涨跌: 当前价 - 昨结
        iRiseFallPercent = 0;//幅度: (当前价 - 昨结)/昨结 * 100
        iDollarExchange = 1;
    }
    void updateRiseFall()
    {
        if (iCurPrice == 0 || iHstClose == 0)
        {
            iRiseFall = 0;
            iRiseFallPercent = 0;
        }
        else
        {
            iRiseFall = (iCurPrice - iHstClose) ;
            iRiseFallPercent = (iRiseFall * 100.0 / iHstClose);
        }
    }
    
    AdvancedQuote operator=(const AdvancedQuote &other)
    {
        iCurPrice = other.iCurPrice;//最新成交价-
        iValue = other.iValue;//成交量
        
        iBidPrice = other.iBidPrice;//买价
        iAskPrice = other.iAskPrice;//卖价
        
        iHigh = other.iHigh;//最高价
        iOpen = other.iOpen;//开盘价
        iLow = other.iLow;//最低价
        iHstClose = other.iHstClose;//昨结
        
        iRiseFall = other.iRiseFall; //涨跌: 当前价 - 昨结
        iRiseFallPercent = other.iRiseFallPercent;//幅度: (当前价 - 昨结)/当前价 * 100
        iDollarExchange = other.iDollarExchange;
        
        if (iValue < 0) iValue = 0;
        
        return *this;
    }
    
    AdvancedQuote(S_AdvancedQuote s_quote)
    {
        
        iCurPrice = s_quote.iCurPrice * Ratio_Number;//最新成交价-
        iValue = s_quote.iValue;//成交量
        
        if (iValue < 0) iValue = 0;
        
        iBidPrice = s_quote.iBidPrice * Ratio_Number;//买价
        iAskPrice = s_quote.iAskPrice * Ratio_Number;//卖价
        
        iHigh = s_quote.iHigh * Ratio_Number;//最高价
        iOpen = s_quote.iOpen * Ratio_Number;//开盘价
        iLow = s_quote.iLow * Ratio_Number;//最低价
        iHstClose = s_quote.iHstClose * Ratio_Number;//昨结
        
        iDollarExchange = s_quote.iDollarExchange;
        
        if (s_quote.iCurPrice == 0 || s_quote.iHstClose == 0)
        {
            iRiseFall = 0;
            iRiseFallPercent = 0;
        }
        else
        {
            iRiseFall = (s_quote.iCurPrice - s_quote.iHstClose);
            iRiseFallPercent = (iRiseFall * 100.0 / s_quote.iHstClose);
            iRiseFall *= Ratio_Number;
        }
        
    }
};

enum QuoteType
{
    QuoteType_TICK = 0,//Tick
    
    QuoteType_MINUTE,//K线1分钟
    
    QuoteType_Item5MINUTES,//5分钟
    
    QuoteType_Item30MINUTES,//30分钟
    
    QuoteType_HOUR,//1小时
    
    QuoteType_DAILY,//天
    
    QuoteType_WEEKLY,//周
    
    QuoteType_MONTHLY,//月
    
    QuoteType_QUARTERLY,//季度
    
    QuoteType_ANNUAL,//年
    
    //==============自定义==============
    QuoteType_2min,
    QuoteType_3min,
    QuoteType_4min,
    QuoteType_10min,
    QuoteType_15min,
    QuoteType_20min,
    
    QuoteType_2hour,
    QuoteType_3hour,
    QuoteType_4hour,
    QuoteType_6hour,
    QuoteType_8hour,
    QuoteType_12hour,
    
    QuoteType_timeShar1min, //分时图
    
    
    QuoteType_MAX,//end
    
    
};

//K线报价
struct KlineQuote
{
    std::string      strCode;
    uint16_t    iTime;// iTime>0 && < QuoteType_MAX
    KlineQuote(const std::string &code, uint16_t time):strCode(code),iTime(time){}
};


struct SortItemInfo
{
    std::string    m_strCodeMarket;
    float        m_fCurPrice;
    float        m_fRiseFallPercent;
    float        m_fAmplitude;
    
    SortItemInfo(){}
    SortItemInfo(const std::string &strCodeMarket, float iCurPrice, float fRiseFallPercent, float fAmplitude)
    :m_strCodeMarket(strCodeMarket), m_fCurPrice(iCurPrice), m_fRiseFallPercent(fRiseFallPercent), m_fAmplitude(fAmplitude){}
};

typedef std::unordered_map<uint16_t, std::string>       SortTypeMap;
typedef std::vector<SortItemInfo>                            SortIDVector;


struct STWarn
{
    uint8_t  iState;//0未触发,1已触发
    
    uint32_t warnID;//从1开始，生命周期内不可修改
    uint32_t warnTime;//定时预警
    uint32_t iUserID;
    
    uint64_t warnMore;//价格预警
    uint64_t warnLess;
    std::string strCodeMarket;
    
    STWarn() :iState(0), warnID(1), warnTime(0), iUserID(0), warnMore(0),warnLess(0){}
    STWarn(MsgPacket &msg) { read(msg); }
    bool operator==(const STWarn &other)
    {
        return warnID == other.warnID;
    }
    bool isTriggerWarn(uint64_t curPrice)
    {
        return (curPrice >= warnMore) || (curPrice <= warnLess);
    }
    void write(MsgPacket &msg)
    {
        msg << iState << iUserID << warnID << strCodeMarket << warnTime << warnMore << warnLess;
    }
    void read(MsgPacket &msg)
    {
        msg >> iState >> iUserID >> warnID >> strCodeMarket >> warnTime >> warnMore >> warnLess;
    }
};

#endif //__Kline_h__
