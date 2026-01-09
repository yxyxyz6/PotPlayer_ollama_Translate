/*
    Real-time subtitle translation for PotPlayer using ollama API
    Optimized for huihui_ai/hy-mt1.5-abliterated
    (Simplified Chinese Localization + Enhanced Subtitle Prompt)
*/

// 插件信息函数
string GetTitle() {
    return "{$CP936=本地 AI 翻译}{$CP0=Local AI Translation$}";
}

string GetVersion() {
    return "1.8"; // 版本号升级，标记提示词更新
}

string GetDesc() {
    return "{$CP936=使用本地 AI 的实时字幕翻译}{$CP0=Real-time subtitle translation using Local AI$}";
}

string GetLoginTitle() {
    return "{$CP936=本地 AI 模型配置}{$CP0=Local AI Model Configuration$}";
}

string GetLoginDesc() {
    return "{$CP936=请输入模型名称（例如 huihui_ai/hy-mt1.5-abliterated:latest）。}{$CP0=Please enter the model name (e.g., huihui_ai/hy-mt1.5-abliterated:latest).$}";
}

string GetUserText() {
    return "{$CP936=模型名称 (当前: " + selected_model + ")}{$CP0=Model Name (Current: " + selected_model + ")$}";
}

string GetPasswordText() {
    return "{$CP936=API 密钥:}{$CP0=API Key:$}";
}

// 全局变量
string DEFAULT_MODEL_NAME = "huihui_ai/hy-mt1.5-abliterated:latest"; 
string api_key = "";
string selected_model = DEFAULT_MODEL_NAME; 
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
string api_url = "http://127.0.0.1:11434/v1/chat/completions";
string api_url_base = "http://127.0.0.1:11434";
string context = "";

// 支持的语言列表
array<string> LangTable = 
{
    "Auto", "af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca",
    "ceb", "ny", "zh-CN",
    "zh-TW", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr",
    "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km",
    "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "ms", "mg", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ps", 
    "fa", "pl", "pt",
    "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk",
    "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu"
};

// 获取源语言列表
array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

// 获取目标语言列表
array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

// 登录接口，用于输入模型名称和 API Key
string ServerLogin(string User, string Pass) {
    // 去除首尾空格
    selected_model = User.Trim();
    api_key = Pass.Trim();

    selected_model.MakeLower();

    array<string> names = GetOllamaModelNames();

    // 验证模型名称是否为空或是否为支持的模型
    if (selected_model.empty()) {
        HostPrintUTF8("{$CP936=未输入模型名称，请输入有效的模型名称。}{$CP0=Model name not entered. Please enter a valid model name.$}\n");
        selected_model = DEFAULT_MODEL_NAME; // 使用默认模型
    }

    int modelscount = names.size();
    if (modelscount == 0){
        return "Ollama未返回模型数据，请确认Ollama已运行 (http://127.0.0.1:11434) 且已下载模型。";
    }
    bool matched = false;
    for (int i = 0; i < modelscount; i++){
        if (selected_model == names[i]){
            matched = true;
            break;
        }
    }
    if (!matched){
        HostPrintUTF8("{$CP936=不支持的模型，请输入已下载的模型名称。}{$CP0=Unsupported model. Please enter a supported model.$}\n");
        return "本地Ollama未找到模型：" + selected_model;
    }

    // 保存设置到临时存储
    HostSaveString("api_key_ollama", api_key);
    HostSaveString("selected_model_ollama", selected_model);
    HostPrintUTF8("{$CP936=API 密钥与模型名称已成功配置。}{$CP0=API Key and model name successfully configured.$}\n");
    return "200 ok";
}

// 登出接口，清除模型名称和 API Key
void ServerLogout() {
    api_key = "";
    selected_model = DEFAULT_MODEL_NAME;
    // 重置为默认模型
    HostSaveString("api_key_ollama", "");
    HostSaveString("selected_model_ollama", selected_model);
    HostPrintUTF8("{$CP936=已成功退出。}{$CP0=Successfully logged out.$}\n");
}

// JSON 字符串转义函数
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    return output;
}

// 翻译函数
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    selected_model = HostLoadString("selected_model_ollama", DEFAULT_MODEL_NAME);

    // 检查目标语言
    if (DstLang.empty() || DstLang == "{$CP936=自动检测}{$CP0=Auto Detect$}") {
        HostPrintUTF8("{$CP936=目标语言未指定。}{$CP0=Target language not specified.$}\n");
        return "";
    }

    string UNICODE_RLE = "\u202B";
    if (SrcLang.empty() || SrcLang == "{$CP936=自动检测}{$CP0=Auto Detect$}") {
        SrcLang = "";
    }

    // --- 构建提示词（集成用户优化的逻辑） ---
    // 强制模型角色：字幕翻译引擎
    string prompt = "你是一个字幕翻译引擎，只负责逐条翻译字幕文本。\n";

    if (!SrcLang.empty()) {
        prompt += "请将以下字幕从" + SrcLang + "翻译为" + DstLang + "。\n";
    } else {
        prompt += "请将以下字幕翻译为" + DstLang + "。\n";
    }

    // 核心规则（字幕安全区）
    prompt += "严格遵守以下规则：\n";
    prompt += "1. 仅输出翻译后的文本，不要包含任何解释、前言、注释或说明。\n";
    prompt += "2. 不要合并、拆分或重排文本行，保持原有行数与顺序不变。\n";
    prompt += "3. 保持原有的换行、标点和格式，适合字幕阅读。\n";
    prompt += "4. 不要补充原文中没有的信息，不要润色或改写语义。\n";
    prompt += "5. 专有名词、人名、数字、符号如无必要请保持不变。\n";

    // 上下文：仅用于理解，不得改写
    if (!context.empty()) {
        prompt += "以下内容仅作为理解语境参考，不要将其翻译或合并进结果：\n";
        prompt += "'''\n" + context + "\n'''\n";
    }

    // 待翻译文本（明确边界）
    prompt += "待翻译字幕文本：\n";
    prompt += "'''\n" + Text + "\n'''";
    // ----------------------------------------

    // JSON 转义
    string escapedPrompt = JsonEscape(prompt);
    // 构建请求数据
    string requestData = "{\"model\":\"" + selected_model + "\",\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}],\"stream\":false}";
    string headers = "Content-Type: application/json";

    // 发送请求
    string response = HostUrlGetString(api_url, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("{$CP936=翻译请求失败。}{$CP0=Translation request failed.$}\n");
        return "";
    }

    // 解析响应
    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("{$CP936=无法解析 API 响应。}{$CP0=Failed to parse API response.$}\n");
        return "";
    }

    JsonValue choices = Root["choices"];
    if (choices.isArray() && choices.size() > 0 && choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        // 简单清理可能残留的引号或空白
        translatedText = translatedText.Trim(); 
        
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText;
    }

    HostPrintUTF8("{$CP936=翻译失败。}{$CP0=Translation failed.$}\n");
    return "";
}

// 插件初始化
void OnInitialize() {
    HostPrintUTF8("{$CP936=ollama 翻译插件已加载。}{$CP0=ollama translation plugin loaded.$}\n");
    
    api_key = HostLoadString("api_key_ollama", "");
    selected_model = HostLoadString("selected_model_ollama", DEFAULT_MODEL_NAME);
    
    if (!api_key.empty()) {
        HostPrintUTF8("{$CP936=已加载保存的配置。}{$CP0=Saved API Key and model name loaded.$}\n");
    }
}

// 插件结束
void OnFinalize() {
    HostPrintUTF8("{$CP936=ollama 翻译插件已卸载。}{$CP0=ollama translation plugin unloaded.$}\n");
}

array<string> GetOllamaModelNames(){
    string url = api_url_base + "/api/tags";
    string headers = "Content-Type: application/json";
    string resp = HostUrlGetString(url,UserAgent, headers, "");
    JsonReader reader;
    JsonValue root;
    if (!reader.parse(resp, root)){
        HostPrintUTF8("{$CP0=Failed to parse the list of the deployed models from Ollama.$}{$CP936=解析Ollama本地模型列表失败：无法解析JSON。}");
        array<string> empty;
        return empty;
    }
    JsonValue models = root["models"];
    int count = models.size();
    int i = 0;
    array<string> res;
    for (i=0 ; i<count;i++){
        res.insertLast(models[i]["name"].asString());
    }
    return res;
}