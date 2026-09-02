<template>
    <section class="meta-section reveal">
        <div class="meta-table-wrap">
            <table class="meta-table">
                <tbody>
                <tr v-for="(m, i) in spec.meta" :key="i" :class="{ acc: m.acc }">
                    <td class="meta-k">{{ m.k }}</td>
                    <td class="meta-v">{{ m.v }}</td>
                </tr>
                </tbody>
            </table>
        </div>
    </section>
</template>

<script>
    export default {
        name: 'MetaTable',
        computed: {
            spec: function () {
                return window.$spec;
            }
        }
    };
</script>