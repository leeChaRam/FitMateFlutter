            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(FitMateTheme.radiusSm)
              ),
              child: FutureBuilder<List<BodyInfoModel>>(
                // 💡 임시로 1번 유저의 조회를 직접 호출하여 태웁니다.
                future: apiService.getRecentBodyInfos(1),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('데이터 로드 실패: ${snapshot.error}', style: const TextStyle(color: Colors.red))),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('저장된 체성분 기록이 없습니다.', style: TextStyle(color: Colors.grey))),
                    );
                  }

                  final historyList = snapshot.data!;

                  return Column(
                    children: List.generate(historyList.length, (index) {
                      final item = historyList[index];
                      
                      // 날짜 문자열 파싱 (예: "2026-06-24" -> "24", "6월")
                      List<String> dateParts = item.measureDate.split('-');
                      String dayStr = dateParts.length > 2 ? dateParts[2] : '00';
                      String monthStr = dateParts.length > 1 ? '${int.parse(dateParts[1])}월' : '1월';

                      return _buildHistoryRow(
                        cs.onSurface, 
                        cs.onSurface.withOpacity(0.5), 
                        Theme.of(context).dividerColor, 
                        dayStr, 
                        monthStr, 
                        item.weight.toString(), 
                        item.muscleMass?.toString() ?? '-', 
                        item.fatMass?.toString() ?? '-', 
                        '', 
                        '', 
                        isFirst: index == historyList.length - 1,
                        isLast: index == historyList.length - 1,
                      );
                    }),
                  );
                },
              ),
            ),