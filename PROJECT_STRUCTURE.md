# 项目结构说明

经过重构后，Todo应用的代码结构变得更加清晰和模块化：

## 目录结构

```
lib/
├── main.dart              # 应用入口点，包含main函数和MyApp根组件
├── models/                # 数据模型层
│   └── todo.dart          # Todo数据模型
├── pages/                 # 页面层
│   ├── home_page.dart     # 主页面（待办事项列表）
│   ├── add_todo_page.dart # 添加待办事项页面
│   └── edit_todo_page.dart# 编辑待办事项页面
└── services/              # 服务层
    ├── storage_helper.dart# 本地存储服务
    └── hitokoto_service.dart# 一言API服务
```

## 模块职责

### 1. main.dart
- 包含应用的入口点`main()`函数
- 定义`MyApp`根组件，设置应用主题和首页

### 2. models/todo.dart
- 定义`Todo`数据模型
- 包含数据序列化和反序列化方法（toJson/fromJson）

### 3. pages/
- **home_page.dart**: 主页面，显示待办事项列表，处理查看、删除等操作
- **add_todo_page.dart**: 添加新待办事项的页面
- **edit_todo_page.dart**: 编辑现有待办事项的页面

### 4. services/
- **storage_helper.dart**: 负责待办事项的本地存储（保存/加载JSON文件）
- **hitokoto_service.dart**: 负责从一言API获取随机句子

## 重构的优势

1. **代码分离**: 每个文件都有明确的职责，便于维护
2. **可重用性**: 服务类可以在不同页面间重复使用
3. **可测试性**: 独立的模块更容易进行单元测试
4. **可扩展性**: 添加新功能时可以在相应的目录中添加新文件
5. **团队协作**: 不同开发者可以同时工作在不同的模块上

## 使用方式

重构后的代码保持了原有的所有功能：
- 添加、编辑、删除待办事项
- 本地数据持久化
- 应用标题栏显示一言句子

所有原有功能都已完整保留，只是代码组织更加合理。
