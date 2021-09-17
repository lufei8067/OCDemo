//
//  MsgPacket.h
//  
//  Created by qiyun on 17-6-16.
//  Copyright (c) 2017 __jin10.com__. All rights reserved.
//
#ifndef __MsgPacket_h__
#define __MsgPacket_h__

#include <iostream> 
#include <cstring>
#include <vector>
#include <stdint.h>

using namespace std;


#define MP_SYNTHESIZE(varType, varName, funName)\
protected: varType varName;\
public: virtual varType Get##funName(void) { return varName; }\
public: virtual void Set##funName(varType var){ varName = var;}


#define OP_CODE_LEN_16	2	//short消息头长
#define OP_CODE_LEN_32	4	//int  消息头长


//////////////////////////////////////////////////////////////////////////
// 字节流缓冲类，可以进行序列化和解序列化操作，并且可以缓冲字节流数据。
//////////////////////////////////////////////////////////////////////////

#define MSG_BUFFER_LEN 65000	//单条消息最长字节

#define SWAP_32_LE(l)                \
            ( ( ((l) >> 24) & 0x000000FFL ) |       \
              ( ((l) >>  8) & 0x0000FF00L ) |       \
              ( ((l) <<  8) & 0x00FF0000L ) |       \
              ( ((l) << 24) & 0xFF000000L ) )

#define SWAP_64_LE(l)            \
            ( ( ((l) >> 56) & 0x00000000000000FFLL ) |       \
              ( ((l) >> 40) & 0x000000000000FF00LL ) |       \
              ( ((l) >> 24) & 0x0000000000FF0000LL ) |       \
              ( ((l) >>  8) & 0x00000000FF000000LL ) |       \
              ( ((l) <<  8) & 0x000000FF00000000LL ) |       \
              ( ((l) << 24) & 0x0000FF0000000000LL ) |       \
              ( ((l) << 40) & 0x00FF000000000000LL ) |       \
              ( ((l) << 56) & 0xFF00000000000000LL ) )


#define SWAP_64_BE(x) ( (x & 0xff00000000000000LL)>>56 | \
						(x & 0x00ff000000000000LL)>>40 | \
						(x & 0x0000ff0000000000LL)>>24 | \
						(x & 0x000000ff00000000LL)>>8  | \
						(x & 0x00000000ff000000LL)<<8  | \
						(x & 0x0000000000ff0000LL)<<24 | \
						(x & 0x000000000000ff00LL)<<40 | \
						(x & 0x00000000000000ffLL)<<56 )

#define SWAP_32_BE(x) ( ((x & 0x000000FF) << 24)| \
						((x & 0x0000FF00) << 8) | \
						((x & 0x00FF0000) >> 8) | \
						((x & 0xFF000000) >> 24) )


class ByteBuffer
{
public:
	const static size_t DEFAULT_BUFFER_SIZE = 1024;

	ByteBuffer() : mReadPos(0), mWritePos(0), mMsgLen(0), mMaxLen(MSG_BUFFER_LEN){ mStorage.reserve(DEFAULT_BUFFER_SIZE); }
	ByteBuffer(size_t res) : mReadPos(0), mWritePos(0), mMsgLen(0), mMaxLen(MSG_BUFFER_LEN) { mStorage.reserve(res); }
	ByteBuffer(const ByteBuffer &buf) : mReadPos(buf.mReadPos), mWritePos(buf.mWritePos), mStorage(buf.mStorage), mMsgLen(buf.mMsgLen), mMaxLen(buf.mMaxLen) {}
	~ByteBuffer() { mStorage.clear(); }

	bool Initialize(const char *data, size_t msgLen)
	{
		if (data == nullptr || msgLen == 0)
		{
			return false;
		}
		clear();
		append(data, msgLen);

		return true;
	}

public:
	void clear()
	{
		mStorage.clear();
		mReadPos = mWritePos = mMsgLen = 0;
	}

	template <typename T>
	void append(T value)
	{
		append((uint8_t*)&value, sizeof(value));
	}

	//////vss 项目专用////////////////////////////////////////////////////////////////////
	void writeMsgLen(uint32_t value)
	{
		char tempc[4];

		tempc[0] = ((value >> 24));
		tempc[1] = ((value >> 16));
		tempc[2] = ((value >> 8));
		tempc[3] = (value);

		put(4, tempc);
	}

	void writeInt32LE(int value)//写入大端int
	{
		char tempc[4];

		tempc[0] = ((value >> 24));
		tempc[1] = ((value >> 16));
		tempc[2] = ((value >> 8));
		tempc[3] = (value);

		append(tempc, 4);
	}

	int32_t readInt32LE()//读取大端int
	{

		int32_t value = read<int32_t>();
		return SWAP_32_LE(value);
	}

	int16_t readInt16LE()
	{
		uint16_t ret = read<uint16_t>();
		return (uint16_t)((ret << 8) | (ret >> 8));
	}

	int64_t readInt64LE()
	{
		int64_t ret = read<int64_t>();
		return SWAP_64_LE(ret);
	}

	std::string readChar(uint16_t len)
	{
		std::string value = "";

		if (mReadPos + len <= storage_size())
		{
			if (len != 0)
			{
				value.append((const char*)&mStorage[mReadPos], (size_t)len);
			}
			mReadPos += len;
		}
		return value;
	}

	//////////////////////////////////////////////////////////////////////////
	template <typename T>
	void put(size_t pos, T value)
	{
		put(pos, (uint8_t*)&value, sizeof(value));
	}

public:
	ByteBuffer& operator<<(bool value)
	{
		append<char>((char)value);
		return *this;
	}
	ByteBuffer& operator<<(char value)
	{
		append<char>((char)value);
		return *this;
	}
	ByteBuffer& operator<<(uint8_t value)
	{
		append<uint8_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(uint16_t value)
	{
		append<uint16_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(uint32_t value)
	{
		append<uint32_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(uint64_t value)
	{
		append<uint64_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(int8_t value)
	{
		append<int8_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(int16_t value)
	{
		append<int16_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(int32_t value)
	{
		append<int32_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(int64_t value)
	{
		append<int64_t>(value);
		return *this;
	}
	ByteBuffer& operator<<(float value)
	{
		append<float>(value);
		return *this;
	}
	ByteBuffer& operator<<(double value)
	{
		append<double>(value);
		return *this;
	}
	ByteBuffer &operator<<(const std::string &value)
	{
		// string length limit 65535
		append<uint16_t>((uint16_t)value.length());
		append((uint8_t *)value.c_str(), value.length());
		return *this;
	}

	//////////////////////////////////////////////////////////////////////////
public:
	ByteBuffer& operator >> (bool& value)
	{
		value = read<char>() > 0 ? true : false;
		return *this;
	}
	ByteBuffer& operator >> (char& value)
	{
		value = read<char>();
		return *this;
	}
	ByteBuffer& operator >> (uint8_t& value)
	{
		value = read<uint8_t>();
		return *this;
	}
	ByteBuffer& operator >> (uint16_t& value)
	{
		value = read<uint16_t>();
		return *this;
	}
	ByteBuffer& operator >> (uint32_t& value)
	{
		value = read<uint32_t>();
		return *this;
	}
	ByteBuffer& operator >> (uint64_t& value)
	{
		value = read<uint64_t>();
		return *this;
	}
	ByteBuffer& operator >> (int8_t& value)
	{
		value = read<int8_t>();
		return *this;
	}
	ByteBuffer& operator >> (int16_t& value)
	{
		value = read<int16_t>();
		return *this;
	}
	ByteBuffer& operator >> (int32_t& value)
	{
		value = read<int32_t>();
		return *this;
	}
	ByteBuffer& operator >> (int64_t& value)
	{
		value = read<int64_t>();
		return *this;
	}
	ByteBuffer& operator >> (float &value)
	{
		value = read<float>();
		return *this;
	}
	ByteBuffer& operator >> (double &value)
	{
		value = read<double>();
		return *this;
	}

	ByteBuffer& operator >> (std::string& value)
	{
		value.clear();
		uint16_t len = read<uint16_t>();
		size_t end = mReadPos + len;

		if (end <= storage_size())
		{
			if (len != 0)
			{
				value.append((const char*)&mStorage[mReadPos], (size_t)len);
			}
			mReadPos = end;
		}

		return *this;

	}

	//////////////////////////////////////////////////////////////////////////
public:
	uint8_t operator[](size_t pos) { return read<uint8_t>(pos); }
	size_t rpos() const { return mReadPos; };
	size_t rpos(size_t rpos_) { mReadPos = rpos_; return mReadPos; };
	size_t wpos() const { return mWritePos; }
	size_t wpos(size_t wpos_) { mWritePos = wpos_; return mWritePos; }
	size_t maxLen(size_t maxlen) { mMaxLen = maxlen; return mMaxLen; }

	template <typename T> T read()
	{
		T r = read<T>(mReadPos);
		mReadPos += sizeof(T);
		return r;
	};
	template <typename T> T read(size_t pos) const
	{

		if (pos + sizeof(T) > storage_size())
		{
			printf("1 read error form [%d] for len:%d\n", pos, sizeof(T));
			return (T)0;
		}
		return *((T const*)&mStorage[pos]);
	}

	bool read(uint8_t *dest, size_t len)
	{
		if (mReadPos + len > storage_size())
		{
			printf("2 read error form [%d] for len:%d\n", mReadPos, len);
			return false;
		}

		memcpy(dest, &mStorage[mReadPos], len);
		mReadPos += len;

		return true;
	}

	const uint8_t* contents() const { return &mStorage[0]; }

	size_t storage_size() const { return mStorage.size(); }
	size_t msg_len() const { return mMsgLen; }

	bool empty() const { return mStorage.empty(); }

	void resize(size_t _NewSize)
	{
		mStorage.resize(_NewSize);
		mReadPos = 0;
		mWritePos = storage_size();
	};

	void reserve(size_t _Size)
	{
		if (_Size > storage_size()) mStorage.reserve(_Size);
	};

	void append(const std::string& str)
	{
		append((uint8_t const*)str.c_str(), str.size() + 1);
	}
	void append(const char *src, size_t cnt)
	{
		return append((const uint8_t *)src, cnt);
	}
	void append(const uint8_t *src, size_t cnt)
	{
		if (!checkResize(cnt)) return;

		memcpy(&mStorage[mWritePos], src, cnt);
		mWritePos += cnt;
		mMsgLen = mWritePos;
	}
	void append(const ByteBuffer& buffer)
	{
		if (buffer.storage_size()) append(buffer.contents(), buffer.storage_size());
	}


	bool readContent(uint8_t * &dest, size_t len)
	{
		if (mReadPos + len > storage_size())
		{
			printf("3 read error form [%d] for len:%d\n", mReadPos, len);
			return false;
		}

		dest = (uint8_t*)(&mStorage[mReadPos], len);
		mReadPos += len;

		return true;
	}
	bool put(size_t pos, const uint8_t *src, size_t cnt)
	{
		if (!checkResize(cnt)) return false;

		memcpy(&mStorage[pos], src, cnt);

		return true;
	}

	bool checkResize(uint32_t cnt)
	{
		if (cnt >= mMaxLen || mStorage.size() + cnt >= mMaxLen)
		{
			printf("buffer size > max len[%u]", mMaxLen);
			return false;
		}

		mStorage.resize((mWritePos + cnt) * 2);
		
		return true;
	}
	//////////////////////////////////////////////////////////////////////////
public:


	bool PrintPosError(bool add, size_t pos, size_t esize) const
	{
		printf("ERROR: Attempt %s in ByteBuffer (pos: %u size: %u) value with size: %u\n", (add ? "put" : "get"), pos, storage_size(), esize);
		return false;
	}

protected:
	size_t					mReadPos;
	size_t					mWritePos;
	size_t					mMsgLen;
	size_t					mMaxLen;//最大长度

	std::vector<uint8_t>	mStorage;
};



class MsgPacket : public ByteBuffer
{
public:
	MsgPacket() :ByteBuffer(), m_senderID(0), m_opcode(0){}
	MsgPacket(const MsgPacket &other)
	{
		m_senderID = 0;
		InitRecvMsg((const char*)other.contents(), other.msg_len());
	}
	virtual ~MsgPacket(){};

	MP_SYNTHESIZE(uint64_t, m_senderID, SenderID);//发送者ID
	MP_SYNTHESIZE(uint32_t, m_opcode, Opcode);//协议ID

	//发送一条 uint16 长的消息
	virtual void InitSendMsg(uint16_t opcode)//server msg
	{
		clear();
		m_opcode = opcode;
		append(opcode);//wpos == OP_CODE_LEN_16
	}
	//发送一条 uint32 长的消息
	virtual void InitSendMsg32(uint32_t opcode)//server msg
	{
		clear();
		m_opcode = opcode;
		append(m_opcode);//wpos == OP_CODE_LEN_32
	}

	//收到一条 uint16 长的消息
	virtual bool InitRecvMsg(const char *data, uint32_t msgLen)
	{
		if (data == nullptr || msgLen < OP_CODE_LEN_16)
		{
			return false;
		}

		ByteBuffer::Initialize(data, msgLen);
		rpos(0);
		wpos(0);
		m_opcode = read<uint16_t>();//初始化头
		wpos(OP_CODE_LEN_16);
		mMsgLen = msgLen;

		return true;
	}

	
	//收到一条 uint32 长的消息
	virtual bool InitRecvMsg32(const char *data, uint32_t msgLen)
	{
		if (data == nullptr || msgLen < OP_CODE_LEN_32)
		{
			return false;
		}

		ByteBuffer::Initialize(data, msgLen);
		rpos(0);
		wpos(0);
		m_opcode = read<uint32_t>();//初始化头
		wpos(OP_CODE_LEN_32);
		mMsgLen = msgLen;

		return true;
	}

	//复制一条消息
	void copy(MsgPacket &msg)
	{
		if (msg.contents() && msg.msg_len() > 0)
		{
			ByteBuffer::Initialize((const char *)msg.contents(), msg.msg_len());
		}
		else
		{
			clear();
		}
	}

	//清空此消息
	void clear()
	{
		m_opcode = 0;
		m_senderID = 0;
		wpos(0);
		rpos(0);
		ByteBuffer::clear();
	}
	//深交所项目修正消息头
	void FixVssRecvMsg()
	{
		m_opcode = SWAP_32_LE(m_opcode);
		rpos(8);//opcode + msglen
	}

	void Encryption(const std::string &_strKey)
	{
		int iKeyLen = _strKey.length();
		if (iKeyLen > 0)
		{
			int iBuffLen = msg_len();
			for (int iIndex = 0; iIndex < iBuffLen; iIndex++)
			{
				mStorage[iIndex] ^= _strKey[iIndex%iKeyLen];
			}
		}

	}

	static void Encryption(uint8_t* srcData, uint32_t srcLen, const std::string &_strKey)
	{
		int iKeyLen = _strKey.length();
		if (iKeyLen > 0 && srcData != nullptr && srcLen > 0)
		{
			for (uint32_t iIndex = 0; iIndex < srcLen; iIndex++)
			{
				srcData[iIndex] ^= _strKey[iIndex%iKeyLen];
			}
		}
	}

protected:


private:

};

#endif // __MsgPacket_h__

