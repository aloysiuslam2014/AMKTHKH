using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Net;
using System.Data.SqlClient;

namespace AMK.Common
{
    public class Utilities
    {
        #region Reporting Service Related
        private static NetworkCredential _nc = null;
        /// <summary>
        /// ReportServerNetworkCredential
        /// </summary>
        public static NetworkCredential ReportServerNetworkCredential
        {
            get
            {
                string userId = ConfigurationManager.AppSettings["RSUser"].ToString();
                string password = ConfigurationManager.AppSettings["RSPassword"].ToString();
                if (password.Length > 0)
                    password = AMK.Common.Utilities.Decrypt(password);
                string domain = ConfigurationManager.AppSettings["RSDomain"].ToString();
                if (_nc == null)
                    _nc = new NetworkCredential(userId, password, domain);
                return _nc;
            }
        }
        /// <summary>
        /// ReportServerUrl
        /// </summary>
        public static string ReportServerUrl
        {
            get
            {
                string rptSvrUrl = ConfigurationManager.AppSettings["RSServerUrl"].ToString();
                return rptSvrUrl;
            }
        }

        /// <summary>
        /// ReportServerUrl
        /// </summary>
        #endregion
        #region Encrypt and Decrypt function

        private static CryptoEngine _crypto = new CryptoEngine(CryptoEngine.AlgorithmType.SHA512);
        public const string CRYPTOKEY = "Secur3AMK";

        /// <summary>
        /// Decrypts specified string value using TripleDES.
        /// </summary>
        /// <param name="input">Encrypted String</param>
        /// <returns></returns>
        public static string Decrypt(string input)
        {
            _crypto.Algorithm = CryptoEngine.AlgorithmType.TripleDES;            
            //_crypto.Algorithm = algorithm;
            return _crypto.Decrypt(input, CRYPTOKEY);
        }

        public static string Encrypt(string input, CryptoEngine.AlgorithmType algorithm)
        {
            _crypto.Algorithm = algorithm;
            return _crypto.Encrypt(input, CRYPTOKEY);
        }
        #endregion

        #region Configuration File
        #region Declaration
        private static string _conStr = string.Empty;
        private static string _webServiceDomain = string.Empty;
        private static string _webServiceUser = string.Empty;
        private static string _webServicePassword = string.Empty;
        private static string _AIC_wsOrgID = string.Empty;
        private static string _AIC_wsUser = string.Empty;
        private static string _AIC_wsPassword = string.Empty;
        private static string _webServiceURL = string.Empty;
        private static string _smtpHOST = string.Empty;
        private static string _indicateCache = string.Empty;
        private static string _indicateWCF = string.Empty;
        private static string _WCFType = string.Empty;
        private static string _LoginType = string.Empty;
        private static string _CompanyCode = string.Empty;
        static readonly string[] serverAliases = { "server", "host", "data source", "datasource", "address", 
                                           "addr", "network address" };
        static readonly string[] databaseAliases = { "database", "initial catalog" };
        static readonly string[] usernameAliases = { "user id", "uid", "username", "user name", "user" };
        static readonly string[] passwordAliases = { "password", "pwd" };
        #endregion


        public static string ConnectionString()
        {
            _conStr = Decrypt(ConfigurationManager.AppSettings["DBconnstr"].ToString());
            return _conStr;
        }

        public static string GetUsername()
        {
            return GetValue(_conStr, usernameAliases);
        }
        public static string GetDBPassword()
        {
            return GetValue(_conStr, passwordAliases);
        }
        public static string GetDatabaseName()
        {
            return GetValue(_conStr, databaseAliases);
        }

        public static string GetServerName()
        {
            return GetValue(_conStr, serverAliases);
        }

        static string GetValue(string connectionString, params string[] keyAliases)
        {
            var keyValuePairs = connectionString.Split(';')
                                                .Where(kvp => kvp.Contains('='))
                                                .Select(kvp => kvp.Split(new char[] { '=' }, 2))
                                                .ToDictionary(kvp => kvp[0].Trim(),
                                                              kvp => kvp[1].Trim(),
                                                              StringComparer.InvariantCultureIgnoreCase);
            foreach (var alias in keyAliases)
            {
                string value;
                if (keyValuePairs.TryGetValue(alias, out value))
                    return value;
            }
            return string.Empty;
        }
        /// <summary>
        /// Returns the empty Date value of the specified application.
        /// </summary>
        /// <param name="database"></param>
        /// <returns></returns>
        public static DateTime EmptyDate()
        {
            DateTime _ret;
            try
            {
                string configurationManagerAppSettingsToString = ConfigurationManager.AppSettings["emptyDate"];
                if (configurationManagerAppSettingsToString == null)
                {
                    DateTime dt = new DateTime(1900, 01, 01);
                    //01/01/1900
                    _ret = Convert.ToDateTime(String.Format("{0:dd/MM/yyyy}", dt).ToString());
                }
                else 
                _ret = Convert.ToDateTime(configurationManagerAppSettingsToString);
            }
            catch
            {
                DateTime dt = new DateTime(1900, 01, 01);
                //01/01/1900
                _ret = Convert.ToDateTime(String.Format("{0:dd/MM/yyyy}", dt).ToString());
            }
            return _ret;
        }
        

        /// Returns the wcf service is been using or not.
        /// </summary>
        public static bool IsUsingWCFService(string wcfServiceName)
        {
            bool retvalue = true;

            try
            {
                if (_indicateWCF == null || _indicateWCF == string.Empty)
                {
                    if (wcfServiceName == "")
                        retvalue = Convert.ToBoolean(ConfigurationManager.AppSettings["WCFService"].ToString());
                    else
                        retvalue = Convert.ToBoolean(ConfigurationManager.AppSettings[wcfServiceName].ToString());

                    _indicateWCF = retvalue.ToString();
                }
                retvalue = Convert.ToBoolean(_indicateWCF);
            }
            catch
            {
                retvalue = false;
            }
            return retvalue;
        }


        /// Returns the webservice Server URL or Address.
        /// </summary>
        public static string WebServiceUrl(string webServiceName)
        {
            //if (_webServiceURL.Equals(string.Empty))
                _webServiceURL = ConfigurationManager.AppSettings[webServiceName].ToString();

            return _webServiceURL;
        }
        /// <summary>
        /// Returns the user name to connect to web service.
        /// </summary>
        public static string WebServiceUser()
        {
            if (_webServiceUser.Equals(string.Empty))
                _webServiceUser = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["wsUserName"].ToString());

            return _webServiceUser;
        }

        /// <summary>
        /// Returns the password to connect to web service
        /// </summary>
        public static string WebServicePassword()
        {
            if (_webServicePassword.Equals(string.Empty))
                _webServicePassword = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["wsPassword"].ToString());

            return _webServicePassword;
        }

        public static string WebServiceDomain()
        {
            if (_webServiceDomain.Equals(string.Empty))
                _webServiceDomain = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["wsDomain"].ToString());

            return _webServiceDomain;
        }

        public static string AICWebServiceUser()
        {
            if (_AIC_wsUser.Equals(string.Empty))
                _AIC_wsUser = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["AIC_wsUser"].ToString());

            return _AIC_wsUser;
        }

        /// <summary>
        /// Returns the password to connect to web service
        /// </summary>
        public static string AICWebServicePassword()
        {
            if (_AIC_wsPassword.Equals(string.Empty))
                _AIC_wsPassword = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["AIC_wsPassword"].ToString());

            return _AIC_wsPassword;
        }

        public static string AICWebServiceOrgID()
        {
            if (_AIC_wsOrgID.Equals(string.Empty))
                _AIC_wsOrgID = AMK.Common.Utilities.Decrypt(ConfigurationManager.AppSettings["AIC_orgID"].ToString());

            return _AIC_wsOrgID;
        }

		public static string SMTPHost()
        {
            if (_smtpHOST.Equals(string.Empty))
                _smtpHOST = ConfigurationManager.AppSettings["SMTPHost"].ToString();
            return _smtpHOST;
        }

        public static string WCFType()
        {
            if (_WCFType.Equals(string.Empty))
                _WCFType = ConfigurationManager.AppSettings["WCFType"].ToString();

            return _WCFType;
        }

        public static string LoginType()
        {
            if (_LoginType.Equals(string.Empty))
                _LoginType = ConfigurationManager.AppSettings["LoginType"].ToString();

            return _LoginType;
        }

        public static bool IsCacheChangeMonitorUI_ON()
        {
            bool retvalue = false;
            try
            {
                if (_indicateCache == null || _indicateCache == string.Empty)
                {
                    retvalue = Convert.ToBoolean(ConfigurationManager.AppSettings["CacheChangeMonitorUI_ON"].ToString());
                    _indicateCache = retvalue.ToString();
                }
            }
            catch
            {
                retvalue = false;
            }
            return retvalue;
        }
        #endregion
    }
}
