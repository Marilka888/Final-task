#!/bin/bash

# Список LTL-свойств для проверки
LTL_LIST=(
  safety_1
  safety_2
  safety_3
  safety_4
  safety_5
  safety_6
  safety_7
  safety_8
  safety_9
  safety_all
  liveness_1
  liveness_2
  liveness_3
  liveness_4
  liveness_5
  liveness_6
  liveness_all
  fairness_1
  fairness_2
  fairness_3
  fairness_4
  fairness_5
  fairness_6
  fairness_all
)

RESULT_DIR="ltl_results"
mkdir -p "$RESULT_DIR"

echo "Начало проверки LTL-свойств с помощью Spin..."

# Инициализация счетчиков
success_count=0
failure_count=0

# Перебор каждого LTL-свойства
for ltl in "${LTL_LIST[@]}"
do
  echo -e "Выполнение проверки: ${ltl}..."

  # Запуск проверки модели Spin
  ./spin -search -m1000000 -ltl $ltl light.pml light.pml > "${RESULT_DIR}/${ltl}.txt"

  # Проверка успешности выполнения команды Spin
  if [ $? -eq 0 ]; then
    echo -e "Проверка ${ltl} успешно завершена! Результат сохранён в ${RESULT_DIR}/${ltl}.txt"
    ((success_count++))  # Увеличиваем счетчик успешных проверок
  else
    echo -e "Ошибка при проверке ${ltl}! Лог в ${RESULT_DIR}/${ltl}.txt"
    ((failure_count++))  # Увеличиваем счетчик неудачных проверок
  fi
done

# Итоговые результаты
echo "Все проверки завершены!"
echo "Успешные проверки: ${success_count}"
echo "Неуспешные проверки: ${failure_count}"
