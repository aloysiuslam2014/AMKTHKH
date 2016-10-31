using System;
using System.Security;
using System.Security.Cryptography;
using System.IO;
using System.Text;

namespace AMK.Common
{
    public class CryptoEngine
    {
        public enum AlgorithmType : int
        {
            None, SHA, SHA256, SHA384, SHA512, MD5,
            DES, RC2, Rijndael, TripleDES, BlowFish, Twofish
        }

        private AlgorithmType _algorithm = AlgorithmType.None;

        public AlgorithmType Algorithm
        {
            get { return _algorithm; }
            set
            {
                _algorithm = value;
                InitializeEngine();
            }
        }

        private bool _isHash;
        public bool IsHashAlgorithm
        {
            get { return _isHash; }
            set { }
        }
        private bool _isSymmetric;
        public bool IsSymmetricAlgorithm
        {
            get { return _isSymmetric; }
            set { }
        }

        private string _key = null;
        public string Key
        {
            get { return _key; }
            set { _key = this.formatKey(value); }
        }

        public string DefaultKey
        {
            get { return _defaultKey; }
            set 
            {
                if (value == string.Empty || value == null)
                {
                    value = _defaultKey;
                }
                _defaultKey = value; 
            }
        }

        //private string DefaultKey = "";
        private string _defaultKey = "Secur3AMK";

        private HashAlgorithmEngine _he;
        private SymmetricAlgorithmEngine _se;

        private string formatKey(string k)
        {
            if (k == null || k.Length == 0) return null;
            return k.Trim();
        }

        public CryptoEngine()
        {
            //DefaultKey = "Secur3Crypt0";
        }

        public CryptoEngine(AlgorithmType al)
        {
            _algorithm = al;
            //DefaultKey = "Secur3Crypt0";

            InitializeEngine();
        }

        public string Decrypt(string src)
        {
            string result = "";

            if (_isSymmetric)
            {
                if (_key == null)
                    result = _se.Decrypting(src, DefaultKey);
                else result = _se.Decrypting(src, _key);
            }

            return result;
        }

        public string Decrypt(string src, string ckey)
        {
            string result = "";

            if (_isSymmetric)
            {
                result = _se.Decrypting(src, ckey);
            }

            return result;
        }

        public string Encrypt(string src)
        {
            string result = "";

            if (_isHash)
            {
                result = _he.Encoding(src);
            }
            else if (_isSymmetric)
            {
                if (_key == null)
                    result = _se.Encrypting(src, DefaultKey);
                else result = _se.Encrypting(src, _key);
            }

            return result;
        }

        public string Encrypt(string src, string ckey)
        {
            string result = "";

            if (_isHash)
            {
                result = _he.Encoding(src);
            }
            else if (_isSymmetric)
            {
                result = _se.Encrypting(src, ckey);
            }

            return result;
        }

        public bool DestroyEngine()
        {
            _se = null;
            _he = null;
            return true;
        }

        public bool InitializeEngine(AlgorithmType at)
        {
            _algorithm = at;

            return InitializeEngine();
        }

        public bool InitializeEngine()
        {
            if (_algorithm == AlgorithmType.None)
                return false;

            if (_algorithm == AlgorithmType.BlowFish ||
                _algorithm == AlgorithmType.DES ||
                _algorithm == AlgorithmType.RC2 ||
                _algorithm == AlgorithmType.Rijndael ||
                _algorithm == AlgorithmType.TripleDES ||
                _algorithm == AlgorithmType.Twofish)
            {
                _isSymmetric = true;
                _isHash = false;
            }
            else
                if (_algorithm == AlgorithmType.MD5 ||
                    _algorithm == AlgorithmType.SHA ||
                    _algorithm == AlgorithmType.SHA256 ||
                    _algorithm == AlgorithmType.SHA384 ||
                    _algorithm == AlgorithmType.SHA512)
                {
                    _isSymmetric = false;
                    _isHash = true;
                }

            _se = null;
            _he = null;
            switch (_algorithm)
            {
                case AlgorithmType.BlowFish:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.BlowFish);
                    break;
                case AlgorithmType.DES:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.DES);
                    break;
                case AlgorithmType.MD5:
                    _he = new HashAlgorithmEngine(HashAlgorithmEngine.EncodeMethodEnum.MD5);
                    break;
                case AlgorithmType.RC2:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.RC2);
                    break;
                case AlgorithmType.Rijndael:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.Rijndael);
                    break;
                case AlgorithmType.SHA:
                    _he = new HashAlgorithmEngine(HashAlgorithmEngine.EncodeMethodEnum.SHA);
                    break;
                case AlgorithmType.SHA256:
                    _he = new HashAlgorithmEngine(HashAlgorithmEngine.EncodeMethodEnum.SHA256);
                    break;
                case AlgorithmType.SHA384:
                    _he = new HashAlgorithmEngine(HashAlgorithmEngine.EncodeMethodEnum.SHA384);
                    break;
                case AlgorithmType.SHA512:
                    _he = new HashAlgorithmEngine(HashAlgorithmEngine.EncodeMethodEnum.SHA512);
                    break;
                case AlgorithmType.TripleDES:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.TripleDES);
                    break;
                case AlgorithmType.Twofish:
                    _se = new SymmetricAlgorithmEngine(SymmetricAlgorithmEngine.EncodeMethodEnum.Twofish);
                    break;
                default:
                    return false;
            }
            return true;
        }

        public class HashAlgorithmEngine
        {
            public enum EncodeMethodEnum : int
            {
                SHA, SHA256, SHA384, SHA512, MD5
            }

            private HashAlgorithm EncodeMethod;

            public HashAlgorithmEngine(HashAlgorithm ServiceProvider)
            {
                EncodeMethod = ServiceProvider;
            }

            public HashAlgorithmEngine(EncodeMethodEnum iSelected)
            {
                switch (iSelected)
                {
                    case EncodeMethodEnum.SHA:
                        EncodeMethod = new SHA1CryptoServiceProvider();
                        break;
                    case EncodeMethodEnum.SHA256:
                        EncodeMethod = new SHA256Managed();
                        break;
                    case EncodeMethodEnum.SHA384:
                        EncodeMethod = new SHA384Managed();
                        break;
                    case EncodeMethodEnum.SHA512:
                        EncodeMethod = new SHA512Managed();
                        break;
                    case EncodeMethodEnum.MD5:
                        EncodeMethod = new MD5CryptoServiceProvider();
                        break;
                }
            }

            public string Encoding(string Source)
            {
                byte[] bytIn = System.Text.ASCIIEncoding.ASCII.GetBytes(Source);

                byte[] bytOut = EncodeMethod.ComputeHash(bytIn);

                // convert into Base64 so that the result can be used in xml
                return System.Convert.ToBase64String(bytOut, 0, bytOut.Length);
            }
        }

        public class SymmetricAlgorithmEngine
        {
            public enum EncodeMethodEnum : int
            {
                DES, RC2, Rijndael, TripleDES, BlowFish, Twofish
            }

            private SymmetricAlgorithm EncodeMethod;

            public SymmetricAlgorithmEngine(SymmetricAlgorithm ServiceProvider)
            {
                EncodeMethod = ServiceProvider;
            }

            public SymmetricAlgorithmEngine(EncodeMethodEnum iSelected)
            {
                switch (iSelected)
                {
                    case EncodeMethodEnum.DES:
                        EncodeMethod = new DESCryptoServiceProvider();
                        break;
                    case EncodeMethodEnum.RC2:
                        EncodeMethod = new RC2CryptoServiceProvider();
                        break;
                    case EncodeMethodEnum.Rijndael:
                        EncodeMethod = new RijndaelManaged();
                        break;
                    case EncodeMethodEnum.TripleDES:
                        EncodeMethod = new TripleDESCryptoServiceProvider();
                        break;
                }
            }

            private byte[] getValidKey(string Key)
            {
                string sTemp;
                if (EncodeMethod.LegalKeySizes.Length > 0)
                {
                    int lessSize = 0, moreSize = EncodeMethod.LegalKeySizes[0].MinSize;
                    // key sizes are in bits

                    while (Key.Length * 8 > moreSize &&
                           EncodeMethod.LegalKeySizes[0].SkipSize > 0 &&
                           moreSize < EncodeMethod.LegalKeySizes[0].MaxSize)
                    {
                        lessSize = moreSize;
                        moreSize += EncodeMethod.LegalKeySizes[0].SkipSize;
                    }

                    if (Key.Length * 8 > moreSize)
                        sTemp = Key.Substring(0, (moreSize / 8));
                    else
                        sTemp = Key.PadRight(moreSize / 8, ' ');
                }
                else
                    sTemp = Key;
                // convert the secret key to byte array
                return ASCIIEncoding.ASCII.GetBytes(sTemp);
            }

            private byte[] getValidIV(String InitVector, int ValidLength)
            {
                if (InitVector.Length > ValidLength)
                {
                    return ASCIIEncoding.ASCII.GetBytes(InitVector.Substring(0, ValidLength));
                }
                else
                {
                    return ASCIIEncoding.ASCII.GetBytes(InitVector.PadRight(ValidLength, ' '));
                }
            }

            public static string BufToStr(byte[] buf)
            {
                StringBuilder result = new StringBuilder(buf.Length * 3);

                for (int nI = 0, nC = buf.Length; nI < nC; nI++)
                {
                    if (0 < nI) result.Append(' ');
                    result.Append(buf[nI].ToString("x2"));
                }
                return result.ToString();
            }

            public string Encrypting(string Source, string Key)
            {
                if (Source == null || Key == null || Source.Length == 0 || Key.Length == 0)
                    return null;

                if (EncodeMethod == null) return "Under Construction";

                long lLen;
                int nRead, nReadTotal;
                byte[] buf = new byte[3];
                byte[] srcData;
                byte[] encData;
                System.IO.MemoryStream sin;
                System.IO.MemoryStream sout;
                CryptoStream encStream;

                srcData = System.Text.ASCIIEncoding.ASCII.GetBytes(Source);
                sin = new MemoryStream();
                sin.Write(srcData, 0, srcData.Length);
                sin.Position = 0;
                sout = new MemoryStream();

                EncodeMethod.Key = getValidKey(Key);
                EncodeMethod.IV = getValidIV(Key, EncodeMethod.IV.Length);

                encStream = new CryptoStream(sout,
                    EncodeMethod.CreateEncryptor(),
                    CryptoStreamMode.Write);
                lLen = sin.Length;
                nReadTotal = 0;
                while (nReadTotal < lLen)
                {
                    nRead = sin.Read(buf, 0, buf.Length);
                    encStream.Write(buf, 0, nRead);
                    nReadTotal += nRead;
                }
                encStream.Close();

                encData = sout.ToArray();
                return System.Convert.ToBase64String(encData);

            }

            public string Decrypting(string Source, string Key)
            {
                if (Source == null || Key == null || Source.Length == 0 || Key.Length == 0)
                    return null;

                if (EncodeMethod == null) return "Under Construction";

                long lLen;
                int nRead, nReadTotal;
                byte[] buf = new byte[3];
                byte[] decData;
                byte[] encData;
                System.IO.MemoryStream sin;
                System.IO.MemoryStream sout;
                CryptoStream decStream;

                encData = System.Convert.FromBase64String(Source);
                sin = new MemoryStream(encData);
                sout = new MemoryStream();

                EncodeMethod.Key = getValidKey(Key);
                EncodeMethod.IV = getValidIV(Key, EncodeMethod.IV.Length);

                decStream = new CryptoStream(sin,
                    EncodeMethod.CreateDecryptor(),
                    CryptoStreamMode.Read);

                lLen = sin.Length;
                nReadTotal = 0;
                while (nReadTotal < lLen)
                {
                    nRead = decStream.Read(buf, 0, buf.Length);
                    if (0 == nRead) break;

                    sout.Write(buf, 0, nRead);
                    nReadTotal += nRead;
                }

                decStream.Close();

                decData = sout.ToArray();

                ASCIIEncoding ascEnc = new ASCIIEncoding();
                return ascEnc.GetString(decData);

            }

        }
    }

}