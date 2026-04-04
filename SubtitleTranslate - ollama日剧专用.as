/*
    Real-time subtitle translation for PotPlayer using ollama API
    [Japanese Special Edition] - Optimized for J-Dramas/Anime nuances
*/

// 插件信息函数
string GetTitle() {
    return "Ollama translation(JP)";
}

string GetVersion() {
    return "1.1_JP";
}

string GetDesc() {
    return "Local AI translation optimized for Japanese";
}

string GetLoginTitle() {
    return "Local AI Model Configuration";
}

string GetLoginDesc() {
    return "Please enter the model name and api key.";
}

string GetUserText() {
    return "Model Name: " + selected_model;
}

string GetPasswordText() {
    return "API Key: " + api_key;
}

// 全局变量
string DEFAULT_MODEL_NAME = "huihui_ai/hy-mt1.5-abliterated:latest"; 
string api_key = "";
string selected_model = DEFAULT_MODEL_NAME; 
string selected_temperature = "0.0";
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
string api_url_base = "http://127.0.0.1:11434";
string api_url_chat = api_url_base + "/api/chat"; 
string api_url_tags = api_url_base + "/api/tags";

// 上下文滑动窗口配置，保留最近 5 句台词作为上下文
array<string> HistoryQueue;
int MAX_HISTORY_LINES = 5; // 

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

// 登录接口
string ServerLogin(string User, string Pass) {
    selected_model = User.Trim();
    api_key = Pass.Trim();
    selected_model.MakeLower();

    array<string> names = GetOllamaModelNames();

    if (selected_model.empty()) {
        selected_model = DEFAULT_MODEL_NAME;
    }

    int modelscount = names.size();
    if (modelscount == 0){
        return "Ollama未返回模型数据，请确认Ollama已运行 (http://127.0.0.1:11434)。";
    }
    bool matched = false;
    for (int i = 0; i < modelscount; i++){
        if (selected_model == names[i]){
            matched = true;
            break;
        }
    }
    if (!matched){
        return "本地Ollama未找到模型: " + selected_model;
    }

    HostSaveString("api_key_ollama_jp", api_key);
    HostSaveString("selected_model_ollama_jp", selected_model);
    return "200 ok";
}

// 登出接口
void ServerLogout() {
    api_key = "";
    selected_model = DEFAULT_MODEL_NAME;
    HostSaveString("api_key_ollama_jp", "");
    HostSaveString("selected_model_ollama_jp", selected_model);
}

// JSON 转义
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
    selected_model = HostLoadString("selected_model_ollama_jp", DEFAULT_MODEL_NAME);
    if (DstLang.empty() || DstLang == "Auto") {
        return "目标语言需明确指定";
    }

    string UNICODE_RLE = "\u202B";
    SrcLang = "ja";

    // 动态构建上下文
    string dynamic_context = "";
    int qSize = HistoryQueue.size();
    if (qSize > 0) {
        for (int i = 0; i < qSize; i++) {
            dynamic_context += "- " + HistoryQueue[i] + "\n"; 
        }
    }

    // 构建提示词
    string prompt = "你是一个专业日语字幕翻译引擎，负责精准翻译日语影视字幕文本。\n";
    prompt += "请将最下方的【待翻译当前日语字幕】翻译为" + DstLang + "。\n";

    // 核心规则
    prompt += "严格遵守以下规则：\n";
    prompt += "1. 仅输出当前字幕的翻译结果，不要包含任何解释、前言、注释或说明。\n";
    prompt += "2. 不要合并、拆分或重排字幕行，保持原有行数、顺序和换行不变。\n";
    prompt += "3. 不要擅自补充主语（如“我 / 你 / 他 / 她”），除非日语原文明确出现。\n";
    prompt += "4. 保留原句的暧昧性和未说完的感觉，不要把含糊表达翻译得过于确定。\n";
    prompt += "5. 正确体现语气词和情绪（如：さ、ね、よ、ぞ、か），用" + DstLang + "语气而非直译。\n";
    prompt += "6. 敬语请翻译为克制、礼貌的" + DstLang + "，而不是书面或官腔表达。\n";
    prompt += "7. 语言风格以自然口语为主，符合日剧对白节奏，避免书面语。\n";

    // 加入上下文隔离限制
    if (!dynamic_context.empty()) {
        prompt += "8. 严禁翻译【近期历史台词】部分的内容！它仅供你参考语境（如代词指代、前言后语）。\n\n";
        prompt += "【近期历史台词（仅供理解语境，切勿翻译）】:\n";
        prompt += "'''\n" + dynamic_context + "'''\n\n";
    } else {
        prompt += "\n";
    }

    // 待翻译文本
    prompt += "【待翻译当前日语字幕】:\n";
    prompt += "'''\n" + Text + "\n'''";

    string escapedPrompt = JsonEscape(prompt);
    string requestData = "{\"model\":\"" + selected_model + "\"," +
                         "\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}]," +
                         "\"options\":{\"temperature\":" + selected_temperature + "}," +
                         "\"stream\":false," +
                         "\"think\":false}";
    string headers = "Content-Type: application/json";
    string response = HostUrlGetString(api_url_chat, UserAgent, headers, requestData);
    if (response.empty()) {
        return "翻译请求失败";
    }

    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        return "无法解析 API 响应";
    }

    JsonValue messageNode = Root["message"];
    if (messageNode.isObject() && messageNode["content"].isString()) {
        string translatedText = messageNode["content"].asString();
        translatedText = translatedText.Trim(); 

        // 上下文队列更新逻辑
        HistoryQueue.insertLast(Text);
        if (HistoryQueue.size() > MAX_HISTORY_LINES) {
            HistoryQueue.removeAt(0);
        }
        
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText;
    }

    return "翻译失败";
}

// 初始化
void OnInitialize() {
    api_key = HostLoadString("api_key_ollama_jp", "");
    selected_model = HostLoadString("selected_model_ollama_jp", DEFAULT_MODEL_NAME);
}

// 结束
void OnFinalize() {
    HistoryQueue.resize(0);
}

// 支持的模型列表
array<string> GetOllamaModelNames(){
    string headers = "Content-Type: application/json";
    string resp = HostUrlGetString(api_url_tags, UserAgent, headers, "");
    JsonReader reader;
    JsonValue root;
    if (!reader.parse(resp, root)){
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