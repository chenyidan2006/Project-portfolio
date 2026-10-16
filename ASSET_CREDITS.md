# 展示站图片来源与修饰说明

## 论文研究图

三张图片均从用户提供的原论文 PDF 提取，保留图内曲线、坐标、文字与连线，不修改实验结果；只裁去页面正文及页眉，网页另附图号与来源。

Zhao, Y., Yao, X., Hu, J., Zhang, Z., and Chen, T. **Cuff-less wearable biosensor in continuous noninvasive human radial artery pulse waveform and blood pressure measurement using self-mixing interferometry.** *Optics Express* 32(24), 42213–42224 (2024). DOI: [10.1364/OE.534566](https://doi.org/10.1364/OE.534566). © 2024 Optica Publishing Group. 原论文载明适用 Optica Open Access Publishing Agreement；本仓库不将这些第三方图片重新声明为自有作品或另授许可。

| 文件 | 论文位置 | 用途 |
| --- | --- | --- |
| dist/assets/paper-fig1-smi-principle.png | Fig.1，刊物第42215页 | 激光内外腔与光反馈原理 |
| dist/assets/paper-fig2-wearable-pipeline.png | Fig.2，刊物第42215页 | 论文可穿戴传感器与处理流程 |
| dist/assets/paper-fig3-signal-reconstruction.png | Fig.3，刊物第42216页 | 原始信号、时频图、相位和重建脉搏波 |

这些是理论来源的研究图，不是陈一丹个人提出的方法、当前原型新测得的曲线或当前App截图。论文实验精度不作为本项目精度，论文中的采集配置不替代本项目固件参数。原论文全文和学长毕业论文未上传展示站。

## 原型照片与真实界面

### 城市道路识别项目

`dist/assets/road-recognition-award.png` 从用户提供的 `CRAIC2026-NF-BFPR6C(1).pdf` 渲染，保留完整证书内容，不修改文字、奖项或姓名。个人首页和独立介绍页仅展示该证书与确认的信息。技术概述和个人分工摘要来自用户指定项目目录中的参赛技术报告第7、59–60页，不发布原报告及其中教师电话，不公开代码或模型。

其余实物照片、奖项证书和App原始截图来自用户提供的项目材料或实际运行截图。`app-hour-current.png` 是2026-10-16运行当前App后截取，使用本地合成示例测量，不是线上患者或用户数据。详情见README。

## 封面修饰图

- 原始照片：`dist/assets/hardware-prototype.jpg`，始终保留。
- 修饰版本：`dist/assets/prototype-retouched.png`。
- 使用内置 image_gen 编辑，非CLI/API脚本。用途为背景清理、色彩平衡和展示质感改善。
- AI图像修饰可能使丝印或微小器件纹理产生偏差，因此网页明确标注“实拍修饰”，点击封面直接查看未修饰原图。接线、器件型号和工程判断以原始资料为准，不依据修饰图。
- 未处理论文研究图、图表结果或App界面截图；未合成新的受试者实验、设备或预测结果。

### 实际使用的完整提示词

Edit target: the provided real hardware prototype photograph. Use case: precise-object-edit / background cleanup. Asset type: wide hero image for a university engineering project portfolio. Retouch this exact photograph into a clean editorial product photograph: remove dust and small scratches ONLY from the black tabletop background, balance white exposure and green PCB colour, slightly improve clarity, make tabletop a uniform very dark blue-black. Keep the EXACT original device, white 3D printed open enclosure, ALL visible circuit-board components, screw locations, connectors, ribbon cable, every coloured wire and their original routing and visible attachments unchanged. Do not invent, add, delete, straighten, relocate or redesign ANY part of the hardware. Preserve original viewpoint, camera perspective and realistic imperfect prototype appearance. Keep entire device visible, a restrained modest 4:3 landscape composition based on original, no extra negative space, no decorative graphics, no text or labels, no logos, no new shadows obscuring details. This is photo retouching, not a product concept render. Preserve board markings as closely as possible. Output a single polished but truthful retouched version.
