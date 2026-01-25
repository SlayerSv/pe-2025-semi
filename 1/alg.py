import itertools


def solve_balance_puzzle():
    # Данные о гирях: (Номер, Масса)
    # Используем кортежи, чтобы различать две гири по 10 кг (одна №6, другая №7)
    weights = [
        (1, 100), (2, 75), (3, 50), (4, 40), 
        (5, 15),  (6, 10), (7, 10)
    ]
    
    # Имена чаш
    bowls_names = ['A', 'B', 'C', 'D', 'E']
    
    # Ограничения задачи:
    # 1. Всего 7 гирь, 5 чаш.
    # 2. В двух чашах по 2 гири, в остальных по 1.
    # Значит, распределение количества гирь по чашам выглядит как перестановка [2, 2, 1, 1, 1]
    
    # Генерируем уникальные варианты распределения количества гирь (кто получает 2, кто 1)
    # set используется для удаления дубликатов перестановок [2,2,1,1,1]
    counts_permutations = sorted(list(set(itertools.permutations([2, 2, 1, 1, 1]))))
    
    # Перебираем все возможные порядки гирь
    for p in itertools.permutations(weights):
        # p - это конкретный порядок гирь, например: (№1, 100), (№7, 10), ...
        
        # Перебираем варианты, сколько гирь класть в каждую чашу
        for counts in counts_permutations:
            
            # Формируем содержимое чаш на основе текущей перестановки и counts
            bowls = {}
            current_idx = 0
            
            for i, name in enumerate(bowls_names):
                count = counts[i]
                bowls[name] = p[current_idx : current_idx + count]
                current_idx += count
            
            # --- ПРОВЕРКА УСЛОВИЙ ЗАДАЧИ ---
            
            # 1. Самая легкая гиря (№7) должна быть в чаше D
            # Проверяем, есть ли гиря с ID 7 в списке гирь чаши D
            ids_in_D = [w[0] for w in bowls['D']]
            if 7 not in ids_in_D:
                continue

            # --- ПРОВЕРКА ФИЗИКИ (Суммы масс) ---
            
            # Считаем суммарную массу в каждой чаше
            m = {name: sum(w[1] for w in content) for name, content in bowls.items()}
            
            # Проверка 1: Рычаг C-D (L7=1, L8=4)
            # Момент слева = Момент справа
            if m['C'] * 1 != m['D'] * 4:
                continue
                
            # Проверка 2: Рычаг (CD)-E (L5=1, L6=2)
            # Масса узла CD = mC + mD
            mass_cd = m['C'] + m['D']
            if mass_cd * 1 != m['E'] * 2:
                continue
            
            # Проверка 3: Рычаг A-B (L3=2, L4=1)
            if m['A'] * 2 != m['B'] * 1:
                continue
                
            # Проверка 4: Главный рычаг (AB)-(CDE) (L1=1, L2=3)
            mass_left = m['A'] + m['B']
            mass_right = mass_cd + m['E'] # (mC + mD + mE)
            
            if mass_left * 1 != mass_right * 3:
                continue
            
            # Если мы здесь, значит решение найдено
            return format_result(bowls)

    return "Решение не найдено"

def format_result(bowls):
    result_list = []
    # Сортируем чаши по алфавиту
    for name in sorted(bowls.keys()):
        for weight in bowls[name]:
            # Формат: (Чаша, Номер гири)
            result_list.append((name, weight[0]))
    return result_list

# Запуск и вывод
solution = solve_balance_puzzle()
print("Найденное решение (Чаша, Номер гири):")
for item in solution:
    print(f"{item[0]} — {item[1]}")
